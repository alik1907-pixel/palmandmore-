extends Node2D
## ŞİŞ game screen: input → BalloonSim, rendering, camera, juice, audio, wordless hints.
## Command line (video/QA): `-- autoplay <first_level> <skill> <seed> [levels_to_play]`

const W := 720.0
const H := 1280.0
const PAL := {
	"bg_top": Color("1d1b3a"), "bg_bot": Color("0c2233"), "wall": Color("d8e2ec"), "wall_edge": Color("8fa3b8"),
	"spike": Color("ff4d5e"), "balloon": Color("ffb547"), "hot": Color("ff3b3b"), "finish": Color("7ee081"),
	"wind": Color(0.55, 0.85, 1.0), "ink": Color("1b1b24"), "white": Color("fffaf0"),
}

var tuning: Tuning
var sim: BalloonSim
var bot: BalloonPlanner = null
var level_num := 1
var autoplay_left := 0
var holding := false
var cam_y := 0.0
var shake := 0.0
var flash := 0.0
var hitstop := 0
var slowmo := 0
var end_timer := 0.0
var particles: Array = []
var trail: Array = []
var wind_streaks: Array = []
var t_anim := 0.0
var blink := 0.0
var held_total := 0.0
var squeezed_once := false
var wind_seen := false
var unlocked := 1
var sfx: Sfx
var _last_tick := 0.0
var _vfx_rng := RandomNumberGenerator.new()

func _ready() -> void:
	tuning = Tuning.load_default()
	sfx = Sfx.new()
	add_child(sfx)
	_load_save()
	level_num = clampi(unlocked, 1, LevelBuilder.level_count())
	var a := OS.get_cmdline_user_args()
	if a.size() >= 1 and a[0] == "autoplay":
		level_num = int(a[1]) if a.size() > 1 else 1
		var skill := float(a[2]) if a.size() > 2 else 1.0
		var seed_v := int(a[3]) if a.size() > 3 else 1
		autoplay_left = int(a[4]) if a.size() > 4 else 1
		bot = BalloonPlanner.new(skill, seed_v)
	_start_level()

func _start_level() -> void:
	sim = BalloonSim.new(LevelBuilder.load_level(level_num), tuning)
	cam_y = sim.center().y - H * 0.68
	end_timer = 0.0
	particles.clear()
	trail.clear()
	if bot != null:
		var next_seed := int(bot.rng.seed) + 1
		seed(next_seed)   # planner shuffles with the global RNG; keep autoplay reproducible
		bot = BalloonPlanner.new(bot.skill, next_seed)
	wind_streaks.clear()
	for i in 40:
		wind_streaks.append(Vector2(_vfx_rng.randf_range(40, 680), _vfx_rng.randf_range(0, H)))

# ---------------------------------------------------------------- input
func _unhandled_input(e: InputEvent) -> void:
	var pressed := false
	var is_press_event := false
	if e is InputEventScreenTouch:
		pressed = e.pressed; is_press_event = true
	elif e is InputEventKey and (e as InputEventKey).keycode == KEY_SPACE and not e.is_echo():
		pressed = e.pressed; is_press_event = true
	if not is_press_event or bot != null:
		return
	holding = pressed
	if pressed and sim.state != "play" and end_timer > 0.35:
		_advance()

func _advance() -> void:
	if sim.state == "won":
		level_num = mini(level_num + 1, LevelBuilder.level_count())
	_start_level()
	holding = false

# ---------------------------------------------------------------- update
func _physics_process(dt: float) -> void:
	t_anim += dt
	if hitstop > 0:
		hitstop -= 1
		queue_redraw()
		return
	var run_sim := true
	if slowmo > 0:
		slowmo -= 1
		run_sim = slowmo % 2 == 0
	if sim.state == "play" and run_sim:
		var hold := holding
		if bot != null:
			hold = bot.decide(sim)
		if hold:
			held_total += dt
		sim.step(hold)
		_handle_events(sim.events)
		var inflating := 0
		if sim.state == "play":
			if hold and sim.target_r < tuning.r_max: inflating = 1
			elif not hold and sim.target_r > tuning.r_min: inflating = -1
		var size01 := inverse_lerp(tuning.r_min, tuning.r_max, sim.target_r)
		sfx.set_loops(inflating, size01, _wind_strength01())
		if sim.over_frames > 0:
			_last_tick += dt * (2.0 + 10.0 * sim.over_ratio())
			if _last_tick > 1.0:
				_last_tick = 0.0
				sfx.play("tick", 1.0 + sim.over_ratio())
	elif sim.state != "play":
		sfx.silence()
		end_timer += dt
		if bot != null and end_timer > 1.4:
			if sim.state == "won":
				autoplay_left -= 1
			if autoplay_left > 0:
				_advance()
	_update_vfx(dt)
	var look := sim.velocity().y * 0.25
	var target := sim.center().y - H * 0.62 + clampf(look, -200.0, 120.0)
	cam_y = lerpf(cam_y, target, 0.1)
	shake = move_toward(shake, 0.0, 0.9)
	flash = move_toward(flash, 0.0, 0.06)
	blink = blink - dt if blink > 0.0 else (0.12 if _vfx_rng.randf() < 0.004 else 0.0)
	queue_redraw()

func _handle_events(evs: Array) -> void:
	for e in evs:
		match String(e.type):
			"pop":
				hitstop = 6
				shake = 22.0
				flash = 1.0
				sfx.play("pop")
				_vibrate(70, 1.0)
				_burst(e.at, 26, PAL.balloon, 520.0, 7.0)
				_burst(e.at, 10, PAL.white, 300.0, 4.0)
			"hit":
				var s: float = e.speed
				sfx.play("squeak", 0.8 + minf(s / 900.0, 0.8), linear_to_db(clampf(s / 700.0, 0.15, 1.0)))
				_burst(e.at, 4, PAL.wall_edge, 140.0, 3.0)
				if s > 500.0:
					shake = maxf(shake, 4.0)
					_vibrate(12, 0.4)
			"squeeze":
				sfx.play("squeeze")
				squeezed_once = true
				_vibrate(20, 0.5)
				_burst(e.at, 8, PAL.finish, 220.0, 3.5)
			"near_miss":
				slowmo = 24
				sfx.play("whoosh")
			"won":
				sfx.play("win")
				_vibrate(40, 0.6)
				_save_progress(level_num + 1)
				for i in 60:
					particles.append({"p": Vector2(_vfx_rng.randf_range(60, 660), cam_y - 20.0),
						"v": Vector2(_vfx_rng.randf_range(-80, 80), _vfx_rng.randf_range(100, 400)), "life": 2.5,
						"size": _vfx_rng.randf_range(5, 10), "col": Color.from_hsv(_vfx_rng.randf(), 0.6, 1.0), "g": 300.0, "spin": true})

func _burst(at: Vector2, n: int, col: Color, speed: float, size: float) -> void:
	for i in n:
		var a := _vfx_rng.randf() * TAU
		particles.append({"p": at, "v": Vector2.from_angle(a) * _vfx_rng.randf_range(speed * 0.3, speed),
			"life": _vfx_rng.randf_range(0.4, 0.9), "size": size * _vfx_rng.randf_range(0.6, 1.3), "col": col, "g": 900.0, "spin": false})

func _update_vfx(dt: float) -> void:
	for p in particles:
		p.v.y += p.g * dt
		p.p += p.v * dt
		p.life -= dt
	particles = particles.filter(func(p): return p.life > 0.0)
	if sim.state == "play":
		trail.push_front(sim.center())
		if trail.size() > 14:
			trail.pop_back()
	for i in wind_streaks.size():
		var s: Vector2 = wind_streaks[i]
		s.x += _wind_at(Vector2(s.x, s.y + cam_y)) * dt * 1.6
		if s.x > 690.0: s.x = 40.0
		if s.x < 30.0: s.x = 680.0
		wind_streaks[i] = s

func _wind_at(p: Vector2) -> float:
	for w in sim.winds:
		if (w.rect as Rect2).has_point(p):
			return float(w.accel)
	return 0.0

func _wind_strength01() -> float:
	return clampf(absf(_wind_at(sim.center())) / 300.0, 0.0, 1.0)

func _vibrate(ms: int, amp: float) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms, amp)

# ---------------------------------------------------------------- save
func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		unlocked = int(cfg.get_value("progress", "unlocked", 1))

func _save_progress(n: int) -> void:
	if bot != null:
		return
	unlocked = maxi(unlocked, mini(n, LevelBuilder.level_count()))
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked", unlocked)
	cfg.save("user://save.cfg")

# ---------------------------------------------------------------- draw
func _draw() -> void:
	var off := Vector2(_vfx_rng.randf_range(-shake, shake), -cam_y + _vfx_rng.randf_range(-shake, shake))
	_draw_background()
	_draw_winds(off)
	var fy: float = sim.finish_y + off.y
	for i in 18:
		var c := PAL.white if i % 2 == 0 else PAL.ink
		draw_rect(Rect2(40 + i * 640.0 / 18.0, fy - 10, 640.0 / 18.0, 20), c)
	for w in sim.walls:
		draw_line(w[0] + off, w[1] + off, PAL.wall_edge, 14.0)
		draw_line(w[0] + off, w[1] + off, PAL.wall, 9.0)
	for s in sim.spikes:
		_draw_spikes(s[0] + off, s[1] + off)
	for i in trail.size():
		var a := 0.18 * (1.0 - float(i) / trail.size())
		draw_circle(trail[i] + off, sim.radius() * 0.35, Color(1, 0.8, 0.4, a))
	_draw_balloon(off)
	for p in particles:
		var col: Color = p.col
		col.a = clampf(p.life * 2.0, 0.0, 1.0)
		if p.spin:
			var r := Rect2(p.p + off - Vector2(p.size, p.size * 0.5), Vector2(p.size * 2.0, p.size))
			draw_rect(r, col)
		else:
			draw_circle(p.p + off, p.size, col)
	_draw_hints(off)
	_draw_hud()
	if flash > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, flash * 0.35))

func _draw_background() -> void:
	var k := sim.progress()
	var top: Color = PAL.bg_top.lerp(Color("2b1d45"), k)
	var bot_c: Color = PAL.bg_bot.lerp(Color("1d1b3a"), k)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(W, 0), Vector2(W, H), Vector2(0, H)]),
		PackedColorArray([top, top, bot_c, bot_c]))
	for i in 30:
		var x := fposmod(i * 137.0, W)
		var y := fposmod(i * 251.0 - cam_y * 0.3, H)
		draw_circle(Vector2(x, y), 2.0 + (i % 3), Color(1, 1, 1, 0.05))

func _draw_winds(off: Vector2) -> void:
	for w in sim.winds:
		var r: Rect2 = w.rect
		draw_rect(Rect2(r.position + off, r.size), Color(PAL.wind.r, PAL.wind.g, PAL.wind.b, 0.05))
	for s in wind_streaks:
		var world := Vector2(s.x, s.y + cam_y)
		var wv := _wind_at(world)
		if wv == 0.0:
			continue
		var d := signf(wv)
		draw_line(Vector2(s.x, s.y), Vector2(s.x - d * 46.0, s.y), Color(PAL.wind.r, PAL.wind.g, PAL.wind.b, 0.35), 3.0)

func _draw_spikes(a: Vector2, b: Vector2) -> void:
	var d := b - a
	var n := maxi(int(d.length() / 20.0), 1)
	var tdir := d.normalized()
	var nrm := Vector2(-tdir.y, tdir.x)
	var step := d.length() / n
	for i in n:
		var p0 := a + tdir * (i * step)
		var p1 := p0 + tdir * step
		var mid := (p0 + p1) * 0.5
		draw_colored_polygon(PackedVector2Array([p0, p1, mid + nrm * 16.0]), PAL.spike)
		draw_colored_polygon(PackedVector2Array([p0, p1, mid - nrm * 16.0]), PAL.spike.darkened(0.2))

func _smooth_outline(off: Vector2) -> PackedVector2Array:
	var n := sim.pos.size()
	var out := PackedVector2Array()
	for i in n:
		var p0: Vector2 = sim.pos[(i - 1 + n) % n]
		var p1: Vector2 = sim.pos[i]
		var p2: Vector2 = sim.pos[(i + 1) % n]
		var p3: Vector2 = sim.pos[(i + 2) % n]
		for k in 3:
			var t := k / 3.0
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3) + off)
	return out

func _draw_balloon(off: Vector2) -> void:
	if sim.state == "popped":
		return
	var heat := sim.over_ratio()
	var stress := clampf((sim.target_r - tuning.r_neutral) / (tuning.r_pop - tuning.r_neutral), 0.0, 1.0)
	var col: Color = PAL.balloon.lerp(PAL.hot, maxf(heat, stress * 0.35))
	var jitter := Vector2(_vfx_rng.randf_range(-1, 1), _vfx_rng.randf_range(-1, 1)) * heat * 4.0
	var pts := _smooth_outline(off + jitter)
	if Geometry2D.triangulate_polygon(pts).is_empty():
		return
	draw_colored_polygon(pts, col)
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, col.darkened(0.35), 4.0, true)
	var c := sim.center() + off + jitter
	var r := sim.radius()
	draw_arc(c + Vector2(-r * 0.15, -r * 0.2), r * 0.62, PI * 1.05, PI * 1.45, 12, Color(1, 1, 1, 0.55), r * 0.12)
	# face
	var v := sim.velocity()
	var look := v.normalized() * minf(v.length() / 300.0, 1.0) * r * 0.08
	var eye_sep := r * 0.32
	var eye_r := r * 0.2
	var scared := _spike_close()
	for sx in [-1.0, 1.0]:
		var e := c + Vector2(sx * eye_sep, -r * 0.12)
		if blink > 0.0 and sim.state == "play":
			draw_line(e - Vector2(eye_r, 0), e + Vector2(eye_r, 0), PAL.ink, 3.0)
			continue
		var er := eye_r * (1.25 if scared else 1.0)
		draw_circle(e, er, PAL.white)
		draw_circle(e + look, er * (0.35 if scared else 0.5), PAL.ink)
		if stress > 0.6:
			draw_line(e + Vector2(-er, -er * 1.4), e + Vector2(er, -er * (1.0 if sx < 0 else 1.8)), PAL.ink, 3.0)
	var mouth_c := c + Vector2(0, r * 0.28)
	if sim.state == "won":
		draw_arc(mouth_c, r * 0.22, 0.2, PI - 0.2, 10, PAL.ink, 4.0)
	elif scared:
		draw_circle(mouth_c, r * 0.1, PAL.ink)
	elif stress > 0.6:
		draw_line(mouth_c - Vector2(r * 0.18, 0), mouth_c + Vector2(r * 0.18, 0), PAL.ink, 4.0)
	else:
		draw_arc(mouth_c - Vector2(0, r * 0.05), r * 0.14, 0.4, PI - 0.4, 8, PAL.ink, 3.0)

func _spike_close() -> bool:
	var c := sim.center()
	var reach := sim.radius() + 60.0
	for s in sim.spikes:
		if c.distance_to(Geometry2D.get_closest_point_to_segment(c, s[0], s[1])) < reach:
			return true
	return false

func _draw_hand(at: Vector2, pressing: bool, alpha: float) -> void:
	var col := Color(1, 1, 1, alpha)
	var tip := at + Vector2(0, 0 if pressing else -26)
	draw_rect(Rect2(tip + Vector2(-16, 18), Vector2(32, 60)), col)
	draw_circle(tip + Vector2(0, 18), 16.0, col)
	draw_circle(tip + Vector2(24, 52), 12.0, col)
	if pressing:
		var ring := fmod(t_anim * 1.5, 1.0)
		draw_arc(at + Vector2(0, 10), 20.0 + ring * 40.0, 0, TAU, 32, Color(1, 1, 1, alpha * (1.0 - ring)), 4.0)
	else:
		draw_line(at + Vector2(-40, -10), at + Vector2(-40, -60), col, 5.0)
		draw_colored_polygon(PackedVector2Array([at + Vector2(-52, -56), at + Vector2(-28, -56), at + Vector2(-40, -76)]), col)

func _draw_hints(off: Vector2) -> void:
	if sim.state != "play":
		return
	var hint: String = sim.level.hint
	var pulse := 0.55 + 0.45 * sin(t_anim * 5.0)
	if hint == "hold" and held_total < 0.6:
		_draw_hand(Vector2(W * 0.5, H * 0.8), true, pulse)
	elif hint == "release" and not squeezed_once:
		for g in sim.level.gates:
			var dist: float = sim.center().y - g.y
			if dist > 0.0 and dist < 300.0 and sim.radius() * 2.0 > g.gap * 0.9:
				_draw_hand(Vector2(W * 0.5, H * 0.8), false, pulse)
				break
	elif hint == "overpop" and sim.over_frames > 0:
		# red, shaking balloon + lifting finger: "let go before it bursts"
		var at := Vector2(W * 0.5, H * 0.82)
		var wob := sin(t_anim * 40.0) * 3.0
		draw_circle(at + Vector2(-70 + wob, 0), 34.0, Color(1, 0.25, 0.25, pulse))
		_draw_hand(at + Vector2(60, -10), false, pulse)
	elif hint == "wind" and not wind_seen:
		if _wind_at(sim.center()) != 0.0:
			var at := Vector2(W * 0.5, H * 0.84)
			var d := signf(_wind_at(sim.center()))
			draw_circle(at + Vector2(-90, 0), 14.0, Color(1, 0.7, 0.3, pulse))
			draw_line(at + Vector2(-70, 0), at + Vector2(-50, 0), Color(1, 1, 1, pulse), 4.0)
			draw_circle(at + Vector2(40, 0), 30.0, Color(1, 0.7, 0.3, pulse))
			draw_line(at + Vector2(80, 0), at + Vector2(80 + 70 * d, 0), Color(1, 1, 1, pulse), 6.0)
			if sim.target_r > tuning.r_neutral + 15.0:
				wind_seen = true

func _draw_hud() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(36, 72), "%d" % level_num, HORIZONTAL_ALIGNMENT_LEFT, -1, 52, PAL.white)
	draw_string(font, Vector2(36 + 22.0 * str(level_num).length() + 20, 70), String(sim.level.name), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1, 1, 1, 0.6))
	var bar := Rect2(W - 30, 140, 10, 520)
	draw_rect(bar, Color(1, 1, 1, 0.12))
	var k := sim.progress()
	draw_rect(Rect2(bar.position.x, bar.end.y - bar.size.y * k, bar.size.x, bar.size.y * k), PAL.finish)
	if sim.state != "play" and end_timer > 0.35:
		var c := Vector2(W * 0.5, H * 0.5)
		var a := clampf((end_timer - 0.35) * 4.0, 0.0, 1.0)
		draw_circle(c, 84.0, Color(0, 0, 0, 0.45 * a))
		if sim.state == "won":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-26, -40), c + Vector2(40, 0), c + Vector2(-26, 40)]), Color(PAL.finish, a))
		else:
			draw_arc(c, 40.0, -PI * 0.2, PI * 1.5, 24, Color(1, 1, 1, a), 10.0)
			var tip := c + Vector2.from_angle(-PI * 0.2) * 40.0
			draw_colored_polygon(PackedVector2Array([tip + Vector2(-16, -14), tip + Vector2(20, -6), tip + Vector2(0, 22)]), Color(1, 1, 1, a))
