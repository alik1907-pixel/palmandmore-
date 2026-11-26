extends Node2D
## ŞİŞ play screen: input → BalloonSim, camera, juice, audio, music mood,
## wordless hints, result/fail panels, rewarded "patch" continue, sharing.

const W := 720.0
const H := 1280.0
const SNAPSHOT_EVERY := 30
const CONTINUE_REWIND := 3          # snapshots back (~1.5 s) when patching

var main: Node
var mode := "level"                 # level | daily
var level_num := 1
var level: Dictionary = {}
var auto := {}
var attempt := 1

var st: ArtStyle
var tuning: Tuning
var sim: BalloonSim
var bot: BalloonPlanner = null
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
var sfx: Sfx
var buttons: Array = []
var pressed_id := ""
var snapshots: Array = []
var continued := false
var result := {}                    # filled on win
var _last_tick := 0.0
var _vfx_rng := RandomNumberGenerator.new()
var _logged_end := false
var _touches := {}

func _notification(what: int) -> void:
	# app sent to background / lost focus: the release event never arrives
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		holding = false
		_touches.clear()

func go_back() -> void:
	_on_button("home")

func _ready() -> void:
	st = main.style
	tuning = Tuning.load_default()
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = not Profile.setting("sound")
	Platform.rewarded_done.connect(_on_rewarded)
	if not auto.is_empty():
		seed(int(auto.seed))
		bot = BalloonPlanner.new(float(auto.skill), int(auto.seed))
	_start()

func _start() -> void:
	sim = BalloonSim.new(level, tuning)
	cam_y = sim.center().y - H * 0.68
	end_timer = 0.0
	particles.clear()
	trail.clear()
	snapshots.clear()
	continued = false
	result = {}
	_logged_end = false
	wind_streaks.clear()
	for i in 40:
		wind_streaks.append(Vector2(_vfx_rng.randf_range(40, 680), _vfx_rng.randf_range(0, H)))
	Analytics.log_event("level_start", {"mode": mode, "level": level_num, "attempt": attempt})

# ---------------------------------------------------------------- input
func _unhandled_input(e: InputEvent) -> void:
	var pressed := false
	var is_press := false
	var pos := Vector2(-1, -1)
	if e is InputEventScreenTouch:
		# multi-touch: hold while ANY finger is down
		if e.pressed: _touches[e.index] = true
		else: _touches.erase(e.index)
		pressed = e.pressed; is_press = true; pos = e.position
	elif e is InputEventKey and (e as InputEventKey).keycode == KEY_SPACE and not e.is_echo():
		pressed = e.pressed; is_press = true
	if not is_press or bot != null:
		return
	if pressed:
		pressed_id = UI.hit(buttons, pos)
		if pressed_id == "" and sim.state == "play":
			holding = true
	else:
		holding = not _touches.is_empty() and e is InputEventScreenTouch
		var id := UI.hit(buttons, pos)
		if id != "" and id == pressed_id:
			_on_button(id)
		pressed_id = ""

func _on_button(id: String) -> void:
	match id:
		"home":
			if sim.state == "play":
				Analytics.log_event("level_quit", {"mode": mode, "level": level_num, "progress": snappedf(sim.progress(), 0.01)})
			main.open_home()
		"retry":
			attempt += 1
			_start()
		"next":
			Platform.maybe_interstitial(int(Profile.data.unlocked) - 1)
			if mode == "level" and level_num < LevelBuilder.level_count():
				main.open_level(main.next_level_after(level_num))
			else:
				main.open_home()
		"patch":
			Platform.show_rewarded("patch")
		"share":
			Platform.share(_share_text())

func _on_rewarded(placement: String, ok: bool) -> void:
	if placement != "patch" or not ok or sim.state != "popped" or snapshots.is_empty():
		return
	var idx := maxi(snapshots.size() - CONTINUE_REWIND, 0)
	sim = (snapshots[idx] as BalloonSim).clone()
	snapshots.resize(idx + 1)
	continued = true
	end_timer = 0.0
	_logged_end = false
	holding = false
	flash = 0.6

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
		if sim.frame % SNAPSHOT_EVERY == 0 and sim.state == "play":
			snapshots.append(sim.clone())
			if snapshots.size() > 8:
				snapshots.pop_front()
		_handle_events(sim.events)
		var inflating := 0
		if sim.state == "play":
			if hold and sim.target_r < tuning.r_max: inflating = 1
			elif not hold and sim.target_r > tuning.r_min: inflating = -1
		var size01 := inverse_lerp(tuning.r_min, tuning.r_max, sim.target_r)
		var wind := _wind_at(sim.center()) != 0.0
		sfx.set_loops(inflating, size01, _wind_strength01())
		Music.set_mood(0.4 + 0.6 * sim.progress(), size01, wind)
		if sim.over_frames > 0:
			_last_tick += dt * (2.0 + 10.0 * sim.over_ratio())
			if _last_tick > 1.0:
				_last_tick = 0.0
				sfx.play("tick", 1.0 + sim.over_ratio())
	elif sim.state != "play":
		sfx.silence()
		end_timer += dt
		if bot != null and end_timer > 1.6:
			_auto_advance()
	_update_vfx(dt)
	var look := sim.velocity().y * 0.25
	var target := sim.center().y - H * 0.62 + clampf(look, -200.0, 120.0)
	cam_y = lerpf(cam_y, target, 0.1)
	main.set_scroll(cam_y)
	shake = move_toward(shake, 0.0, 0.9)
	flash = move_toward(flash, 0.0, 0.06)
	blink = blink - dt if blink > 0.0 else (0.12 if _vfx_rng.randf() < 0.004 else 0.0)
	queue_redraw()

func _auto_advance() -> void:
	if sim.state == "won":
		auto.count = int(auto.count) - 1
		if int(auto.count) > 0 and mode == "level" and level_num < LevelBuilder.level_count():
			var a := auto.duplicate()
			a.seed = int(a.seed) + 1
			main.open_level(level_num + 1, a)
		return
	attempt += 1
	auto.seed = int(auto.seed) + 1
	seed(int(auto.seed))
	bot = BalloonPlanner.new(float(auto.skill), int(auto.seed))
	_start()

func _stars_for(seconds: float) -> int:
	if continued:
		return 1
	var par := float(level.get("par", 20.0))
	if seconds <= par * 1.35:
		return 3
	if seconds <= par * 2.0:
		return 2
	return 1

func _handle_events(evs: Array) -> void:
	for e in evs:
		match String(e.type):
			"pop":
				hitstop = 6
				shake = 22.0
				flash = 1.0
				sfx.play("pop")
				_vibrate(70, 1.0)
				_burst(e.at, 26, _balloon_color(), 520.0, 7.0)
				_burst(e.at, 10, st.c.white, 300.0, 4.0)
				if not _logged_end:
					_logged_end = true
					Analytics.log_event("level_fail", {"mode": mode, "level": level_num, "attempt": attempt, "cause": e.cause,
						"x": int(e.at.x), "y": int(e.at.y), "progress": snappedf(sim.progress(), 0.01), "sec": snappedf(sim.frame / 60.0, 0.1)})
			"hit":
				var s: float = e.speed
				sfx.play("squeak", 0.8 + minf(s / 900.0, 0.8), linear_to_db(clampf(s / 700.0, 0.15, 1.0)))
				_burst(e.at, 4, st.c.wall_edge, 140.0, 3.0)
				if s > 500.0:
					shake = maxf(shake, 4.0)
					_vibrate(12, 0.4)
			"squeeze":
				sfx.play("squeeze")
				squeezed_once = true
				_vibrate(20, 0.5)
				_burst(e.at, 8, st.c.finish, 220.0, 3.5)
			"near_miss":
				slowmo = 24
				sfx.play("whoosh")
			"won":
				sfx.play("win")
				_vibrate(40, 0.6)
				_on_won()
				for i in 60:
					particles.append({"p": Vector2(_vfx_rng.randf_range(60, 660), cam_y - 20.0),
						"v": Vector2(_vfx_rng.randf_range(-80, 80), _vfx_rng.randf_range(100, 400)), "life": 2.5,
						"size": _vfx_rng.randf_range(5, 10), "col": Color.from_hsv(_vfx_rng.randf(), 0.6, 1.0), "g": 300.0, "spin": true})

func _on_won() -> void:
	var sec := sim.frame / 60.0
	var stars := _stars_for(sec)
	result = {"sec": sec, "stars": stars}
	if bot != null:
		return
	if mode == "level":
		var r := Profile.record_level(level_num, stars, sec if not continued else 9999.0)
		result.merge(r)
		if level_num == 6 and stars == 3 and not Profile.data.get("review_asked", false):
			Profile.data.review_asked = true
			Profile.save()
			Platform.request_review()
	else:
		var r2 := Profile.record_daily(sec)
		result.merge(r2)
	Analytics.log_event("level_complete", {"mode": mode, "level": level_num, "attempt": attempt, "sec": snappedf(sec, 0.1),
		"stars": stars, "continued": continued})

func _share_text() -> String:
	var stars := "⭐".repeat(int(result.get("stars", 1)))
	var sec := "%.1f" % float(result.get("sec", 0.0))
	var link := Platform.cfg.store_url
	if mode == "daily":
		return (I18n.t("share_daily") % [level_num, sec, stars, Profile.streak_alive()]) + "\n" + link
	return (I18n.t("share_level") % [level_num, sec, stars]) + "\n" + link

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
	if OS.has_feature("mobile") and Profile.setting("haptics"):
		Input.vibrate_handheld(ms, amp)

func _balloon_color() -> Color:
	return Skins.base_color(String(Profile.data.skin), st)

# ---------------------------------------------------------------- draw
func _draw() -> void:
	buttons.clear()
	var off := Vector2(_vfx_rng.randf_range(-shake, shake), -cam_y + _vfx_rng.randf_range(-shake, shake))
	if st.stars:
		for i in 30:
			var x := fposmod(i * 137.0, W)
			var y := fposmod(i * 251.0 - cam_y * 0.3, H)
			draw_circle(Vector2(x, y), 2.0 + (i % 3), Color(1, 1, 1, 0.08))
	_draw_winds(off)
	var fy: float = sim.finish_y + off.y
	for i in 18:
		draw_rect(Rect2(40 + i * 640.0 / 18.0, fy - 10, 640.0 / 18.0, 20), st.c.white if i % 2 == 0 else st.c.ink)
	for w in sim.walls:
		st.draw_wall(self, w[0] + off, w[1] + off)
	for s in sim.spikes:
		st.draw_spikes(self, s[0] + off, s[1] + off)
	var bc := _balloon_color()
	for i in trail.size():
		var a := 0.18 * (1.0 - float(i) / trail.size())
		draw_circle(trail[i] + off, sim.radius() * 0.35, Color(bc, a))
	_draw_balloon(off)
	for p in particles:
		var col: Color = p.col
		col.a = clampf(p.life * 2.0, 0.0, 1.0)
		if p.spin:
			draw_rect(Rect2(p.p + off - Vector2(p.size, p.size * 0.5), Vector2(p.size * 2.0, p.size)), col)
		else:
			draw_circle(p.p + off, p.size, col)
	_draw_hints()
	_draw_hud()
	if flash > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, flash * 0.35))
	if sim.state != "play" and end_timer > 0.35:
		_draw_end_panel()

func _draw_winds(off: Vector2) -> void:
	for w in sim.winds:
		var r: Rect2 = w.rect
		draw_rect(Rect2(r.position + off, r.size), Color(st.c.wind, 0.06))
	for s in wind_streaks:
		var wv := _wind_at(Vector2(s.x, s.y + cam_y))
		if wv == 0.0:
			continue
		var d := signf(wv)
		draw_line(Vector2(s.x, s.y), Vector2(s.x - d * 46.0, s.y), Color(st.c.wind, 0.45), 3.0)

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
	var base := _balloon_color()
	var col: Color = base.lerp(st.c.hot, maxf(heat, stress * 0.3))
	var jitter := Vector2(_vfx_rng.randf_range(-1, 1), _vfx_rng.randf_range(-1, 1)) * heat * 4.0
	var pts := _smooth_outline(off + jitter)
	if Geometry2D.triangulate_polygon(pts).is_empty():
		return
	var c := sim.center() + off + jitter
	var r := sim.radius()
	if st.wall_shadow != Vector2.ZERO:
		var sh := PackedVector2Array()
		for p in pts: sh.append(p + st.wall_shadow * 0.8)
		draw_colored_polygon(sh, Color(0, 0, 0, 0.16))
	if st.wall_glow:
		draw_circle(c, r * 1.25, Color(col, 0.18))
	draw_colored_polygon(pts, col)
	Skins.draw_pattern(self, String(Profile.data.skin), pts, c, r, t_anim)
	if st.halftone:
		for k in 14:
			var a := 0.5 + k * 0.22
			var p := c + Vector2.from_angle(a) * r * (0.55 + 0.1 * (k % 3))
			draw_circle(p, r * 0.045, Color(0, 0, 0, 0.12))
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, st.c.ink if st.balloon_outline > 0.0 else col.darkened(0.35), maxf(st.balloon_outline, 4.0), true)
	draw_arc(c + Vector2(-r * 0.15, -r * 0.2), r * 0.62, PI * 1.05, PI * 1.45, 12, Color(1, 1, 1, 0.55), r * 0.12)
	var v := sim.velocity()
	var look := v.normalized() * minf(v.length() / 300.0, 1.0) * r * 0.08
	var eye_r := r * 0.2
	var scared := _spike_close()
	for sx in [-1.0, 1.0]:
		var e := c + Vector2(sx * r * 0.32, -r * 0.12)
		if blink > 0.0 and sim.state == "play":
			draw_line(e - Vector2(eye_r, 0), e + Vector2(eye_r, 0), st.c.ink, 3.0)
			continue
		var er := eye_r * (1.25 if scared else 1.0)
		draw_circle(e, er, st.c.white)
		draw_circle(e + look, er * (0.35 if scared else 0.5), st.c.ink)
		if stress > 0.6:
			draw_line(e + Vector2(-er, -er * 1.4), e + Vector2(er, -er * (1.0 if sx < 0 else 1.8)), st.c.ink, 3.0)
	var mouth_c := c + Vector2(0, r * 0.28)
	if sim.state == "won":
		draw_arc(mouth_c, r * 0.22, 0.2, PI - 0.2, 10, st.c.ink, 4.0)
	elif scared:
		draw_circle(mouth_c, r * 0.1, st.c.ink)
	elif stress > 0.6:
		draw_line(mouth_c - Vector2(r * 0.18, 0), mouth_c + Vector2(r * 0.18, 0), st.c.ink, 4.0)
	else:
		draw_arc(mouth_c - Vector2(0, r * 0.05), r * 0.14, 0.4, PI - 0.4, 8, st.c.ink, 3.0)

func _spike_close() -> bool:
	var c := sim.center()
	var reach := sim.radius() + 60.0
	for s in sim.spikes:
		if c.distance_to(Geometry2D.get_closest_point_to_segment(c, s[0], s[1])) < reach:
			return true
	return false

func _draw_hand(at: Vector2, pressing: bool, alpha: float) -> void:
	var col := Color(st.c.ui, alpha)
	var tip := at + Vector2(0, 0 if pressing else -26)
	draw_rect(Rect2(tip + Vector2(-16, 18), Vector2(32, 60)), col)
	draw_circle(tip + Vector2(0, 18), 16.0, col)
	draw_circle(tip + Vector2(24, 52), 12.0, col)
	if pressing:
		var ring := fmod(t_anim * 1.5, 1.0)
		draw_arc(at + Vector2(0, 10), 20.0 + ring * 40.0, 0, TAU, 32, Color(st.c.ui, alpha * (1.0 - ring)), 4.0)
	else:
		draw_line(at + Vector2(-40, -10), at + Vector2(-40, -60), col, 5.0)
		draw_colored_polygon(PackedVector2Array([at + Vector2(-52, -56), at + Vector2(-28, -56), at + Vector2(-40, -76)]), col)

func _draw_hints() -> void:
	if sim.state != "play":
		return
	var hint: String = sim.level.get("hint", "")
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
		var at := Vector2(W * 0.5, H * 0.82)
		draw_circle(at + Vector2(-70 + sin(t_anim * 40.0) * 3.0, 0), 34.0, Color(st.c.hot, pulse))
		_draw_hand(at + Vector2(60, -10), false, pulse)
	elif hint == "wind" and not wind_seen and _wind_at(sim.center()) != 0.0:
		var at2 := Vector2(W * 0.5, H * 0.84)
		var d := signf(_wind_at(sim.center()))
		draw_circle(at2 + Vector2(-90, 0), 14.0, Color(_balloon_color(), pulse))
		draw_line(at2 + Vector2(-70, 0), at2 + Vector2(-50, 0), Color(st.c.ui, pulse), 4.0)
		draw_circle(at2 + Vector2(40, 0), 30.0, Color(_balloon_color(), pulse))
		draw_line(at2 + Vector2(80, 0), at2 + Vector2(80 + 70 * d, 0), Color(st.c.ui, pulse), 6.0)
		if sim.target_r > tuning.r_neutral + 15.0:
			wind_seen = true

func _btn(id: String, r: Rect2, label: String, primary: bool, icon := "") -> void:
	UI.button(self, r, label, st, primary, true, pressed_id == id)
	if icon != "":
		UI.icon(self, icon, r.get_center() + Vector2(0, 0 if pressed_id != id else 5), 26.0, Color.WHITE)
	buttons.append({"id": id, "rect": r})

func _draw_hud() -> void:
	var ink: Color = st.c.ui
	_btn("home", Rect2(24, 28, 76, 76), "", false, "home")
	var title := ("#%d " % level_num) + I18n.t("daily") if mode == "daily" else "%d  %s" % [level_num, I18n.level_name(level_num)]
	UI.text_left(self, title, Vector2(120, 80), 34, ink)
	var bar := Rect2(W - 30, 140, 10, 520)
	draw_rect(bar, Color(ink, 0.15))
	var k := sim.progress()
	draw_rect(Rect2(bar.position.x, bar.end.y - bar.size.y * k, bar.size.x, bar.size.y * k), st.c.finish)
	if sim.state == "play":
		UI.text_left(self, "%.1f" % (sim.frame / 60.0), Vector2(W - 120, 80), 30, Color(ink, 0.7))

func _draw_end_panel() -> void:
	var a := clampf((end_timer - 0.35) * 4.0, 0.0, 1.0)
	var r := Rect2(70, 420, W - 140, 470)
	UI.panel(self, r, st, 0.95 * a)
	var ink: Color = st.c.ink if st.id != "gece" else Color.WHITE
	if sim.state == "won":
		var stars := int(result.get("stars", 1))
		for i in 3:
			UI.star(self, Vector2(W * 0.5 + (i - 1) * 90, r.position.y + 90 - (14 if i == 1 else 0)), 38.0, i < stars)
		UI.text_center(self, "%.1f s" % float(result.get("sec", 0.0)), Vector2(W * 0.5, r.position.y + 200), 54, ink)
		if mode == "daily":
			UI.icon(self, "flame", Vector2(W * 0.5 - 40, r.position.y + 250), 22.0, Color.WHITE)
			UI.text_left(self, str(Profile.streak_alive()), Vector2(W * 0.5 - 10, r.position.y + 265), 36, ink)
		var unl: Array = result.get("unlocks", [])
		if not unl.is_empty():
			UI.text_center(self, I18n.t("new_unlock"), Vector2(W * 0.5, r.position.y + 300), 30, st.c.finish)
		_btn("home", Rect2(r.position.x + 30, r.end.y - 130, 140, 100), "", false, "home")
		_btn("share", Rect2(r.position.x + 190, r.end.y - 130, 140, 100), "", false, "share")
		_btn("next", Rect2(r.position.x + 350, r.end.y - 130, r.size.x - 380, 100), "", true, "next")
	else:
		UI.icon(self, "retry", Vector2(W * 0.5, r.position.y + 110), 48.0, Color(ink, 0.8))
		UI.text_center(self, "%d%%" % int(sim.progress() * 100.0), Vector2(W * 0.5, r.position.y + 230), 48, ink)
		var can_patch := not continued and not snapshots.is_empty() and sim.state == "popped" and Platform.rewarded_available()
		if can_patch:
			_btn("patch", Rect2(r.position.x + 30, r.end.y - 250, r.size.x - 60, 96), I18n.t("patch"), true)
			UI.icon(self, "film", Vector2(r.position.x + 80, r.end.y - 202), 18.0, Color.WHITE)
		_btn("home", Rect2(r.position.x + 30, r.end.y - 130, 140, 100), "", false, "home")
		_btn("retry", Rect2(r.position.x + 190, r.end.y - 130, r.size.x - 220, 100), "", not can_patch, "retry")
