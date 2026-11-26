extends Node2D
## Greybox renderer for KIRILMA. Tap a shard to crack it along its grain.
## `-- autoplay <level> <skill> <seed>` lets a bot play (video capture).

var sim: KirSim
var bot: KirBot = null
var level_index := 0
var falling: Array = []   # {poly, vel, rot, spin, pos, life}
var t := 0
var next_bot_tap := 60
var flash := 0.0
var shake := 0.0

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1 and args[0] == "autoplay":
		level_index = int(args[1])
		bot = KirBot.new(float(args[2]) if args.size() > 2 else 1.0, int(args[3]) if args.size() > 3 else 1)
	sim = KirSim.new(KirLevels.make(level_index))

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch and e.pressed:
		if sim.state != "play":
			if sim.state == "won": level_index += 1
			sim = KirSim.new(KirLevels.make(level_index))
			falling.clear()
			return
		_do_tap(e.position)

func _do_tap(p: Vector2) -> void:
	sim.tap(p)
	if sim.last_fallen.size() > 0:
		shake = min(4.0 + sim.last_fallen.size() * 0.15, 16.0)
		flash = 1.0
	for i in sim.last_fallen:
		var c: Vector2 = sim.sites[i]
		var local := PackedVector2Array()
		for v in sim.polys[i]:
			local.append(v - c)
		var away: Vector2 = (c - p).normalized()
		falling.append({"poly": local, "pos": c, "vel": away * randf_range(40, 160) + Vector2(0, -randf_range(0, 120)),
			"rot": 0.0, "spin": randf_range(-4, 4), "target": sim.is_target[i]})

func _physics_process(dt: float) -> void:
	t += 1
	if bot != null and sim.state == "play" and t >= next_bot_tap:
		_do_tap(bot.choose(sim))
		next_bot_tap = t + 30
	for f in falling:
		f.vel.y += 1400.0 * dt
		f.pos += f.vel * dt
		f.rot += f.spin * dt
	falling = falling.filter(func(f): return f.pos.y < 1500.0)
	shake = move_toward(shake, 0.0, 0.7)
	flash = move_toward(flash, 0.0, 0.08)
	queue_redraw()

func _draw() -> void:
	var off := Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	draw_rect(Rect2(0, 0, 720, 1280), Color("14121f"))
	# hook
	draw_line(Vector2(360, 120) + off, Vector2(360, KirSim.TOP) + off, Color("8a8fa3"), 6.0)
	draw_circle(Vector2(360, 120) + off, 12.0, Color("8a8fa3"))
	for i in sim.sites.size():
		if not sim.alive[i]:
			continue
		var col := Color("9fd3ff") if not sim.is_target[i] else Color("ffd27a")
		var poly: PackedVector2Array = sim.polys[i]
		var moved := PackedVector2Array()
		for v in poly: moved.append(v + off)
		draw_colored_polygon(moved, col.darkened(0.15 if i % 3 == 0 else 0.0))
		moved.append(moved[0])
		draw_polyline(moved, Color(1, 1, 1, 0.55), 1.5)
		var g := Vector2(cos(sim.grain[i]), sin(sim.grain[i])) * sim.spacing * 0.28
		draw_line(sim.sites[i] - g + off, sim.sites[i] + g + off, Color(0.1, 0.2, 0.35, 0.55), 2.0)
	var outline := sim.target_poly.duplicate()
	outline.append(outline[0])
	for k in outline.size():
		outline[k] += off
	draw_polyline(outline, Color(1, 0.85, 0.4, 0.35), 2.0)
	for f in falling:
		var xf := Transform2D(f.rot, f.pos)
		var pts := xf * (f.poly as PackedVector2Array)
		draw_colored_polygon(pts, (Color("ffd27a") if f.target else Color("9fd3ff")).darkened(0.25))
	if flash > 0.0:
		draw_rect(Rect2(0, 0, 720, 1280), Color(1, 1, 1, flash * 0.12))
	var c := sim.counts()
	draw_string(ThemeDB.fallback_font, Vector2(40, 70), "KIRILMA • Bölüm %d" % (level_index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(40, 1180), "Vuruş: %d   Kalan buz: %d%%   Süs hasarı: %d%%" % [sim.taps_left, int(c.leftover * 100), int(c.loss * 100)], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
	var msg := "ORTAYA ÇIKTI!" if sim.state == "won" else ("KIRILDI" if sim.state == "lost" else "")
	if msg != "":
		draw_string(ThemeDB.fallback_font, Vector2(0, 1110), msg, HORIZONTAL_ALIGNMENT_CENTER, 720, 64, Color.WHITE)
