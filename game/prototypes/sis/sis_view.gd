extends Node2D
## Greybox renderer + input for ŞİŞ. Hold anywhere = inflate.
## Autoplay (bot) when launched with `-- autoplay <level> <skill>` (used for video capture).

var sim: SisSim
var bot: SisBot = null
var level_index := 0
var holding := false
var cam_y := 0.0
var shake := 0.0
var squash_flash := 0.0

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1 and args[0] == "autoplay":
		level_index = int(args[1]) if args.size() > 1 else 0
		var skill := float(args[2]) if args.size() > 2 else 1.0
		bot = SisBot.new(skill, int(args[3]) if args.size() > 3 else 1)
	_reset()

func _reset() -> void:
	sim = SisSim.new(SisLevels.make(level_index))
	cam_y = sim.center().y - 900.0

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		holding = e.pressed
		if e.pressed and sim.state != "play":
			if sim.state == "won":
				level_index += 1
			_reset()

func _physics_process(_d: float) -> void:
	var hold := holding
	if bot != null:
		hold = bot.decide(sim)
	var before := sim.state
	sim.step(hold)
	if before == "play" and sim.state == "popped":
		shake = 18.0
	if bot != null and sim.state != "play" and sim.frame > 0:
		pass
	shake = move_toward(shake, 0.0, 0.8)
	var target := sim.center().y - 820.0
	cam_y = lerp(cam_y, target, 0.08)
	queue_redraw()

func _draw() -> void:
	var off := Vector2(randf_range(-shake, shake), -cam_y + randf_range(-shake, shake))
	draw_rect(Rect2(0, 0, 720, 1280), Color("0f1a24"))
	for w in sim.winds:
		var r: Rect2 = w[0]
		draw_rect(Rect2(r.position + off, r.size), Color(0.3, 0.6, 1.0, 0.07))
		var dir: float = sign(w[1])
		for i in 6:
			var y := r.position.y + r.size.y * (i + 0.5) / 6.0
			var x := fposmod(sim.frame * 4.0 * dir + i * 97.0, r.size.x) + r.position.x
			draw_line(Vector2(x, y) + off, Vector2(x - dir * 40.0, y) + off, Color(0.5, 0.8, 1.0, 0.35), 3.0)
	for w in sim.walls:
		draw_line(w[0] + off, w[1] + off, Color("c9d6df"), 6.0)
	for s in sim.spikes:
		_draw_spikes(s[0] + off, s[1] + off)
	draw_line(Vector2(0, sim.finish_y) + off, Vector2(720, sim.finish_y) + off, Color("7ee081"), 4.0)
	# balloon
	var pts := PackedVector2Array()
	for p in sim.pos:
		pts.append(p + off)
	var stress: float = clamp((sim.target_r - SisSim.R_NEUTRAL) / (SisSim.R_POP - SisSim.R_NEUTRAL), 0.0, 1.0)
	var col := Color("f2aa4c").lerp(Color("ff3b3b"), stress)
	if sim.state == "popped":
		for i in sim.pos.size():
			var p: Vector2 = sim.pos[i] + off
			var c: Vector2 = sim.center() + off
			draw_line(p, p + (p - c) * 0.6, col, 5.0)
	else:
		if Geometry2D.triangulate_polygon(pts).size() > 0:
			draw_colored_polygon(pts, col)
		pts.append(pts[0])
		draw_polyline(pts, col.lightened(0.3), 3.0)
		var c := sim.center() + off
		var r := sim.radius()
		draw_circle(c + Vector2(-r * 0.3, -r * 0.15), r * 0.12, Color.BLACK)
		draw_circle(c + Vector2(r * 0.3, -r * 0.15), r * 0.12, Color.BLACK)
	var msg := ""
	if sim.state == "won": msg = "GEÇTİN!"
	elif sim.state == "popped": msg = "PATLADIN"
	elif sim.state == "stuck": msg = "TAKILDIN"
	draw_string(ThemeDB.fallback_font, Vector2(40, 90), "ŞİŞ  •  Bölüm %d" % (level_index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color.WHITE)
	if msg != "":
		draw_string(ThemeDB.fallback_font, Vector2(0, 640), msg, HORIZONTAL_ALIGNMENT_CENTER, 720, 72, Color.WHITE)

func _draw_spikes(a: Vector2, b: Vector2) -> void:
	var d := b - a
	var n := int(d.length() / 18.0)
	var t := d.normalized()
	var nrm := Vector2(-t.y, t.x)
	for i in maxi(n, 1):
		var p0 := a + t * (i * 18.0)
		var p1 := p0 + t * 18.0
		var tip := (p0 + p1) * 0.5
		draw_colored_polygon(PackedVector2Array([p0, p1, tip + nrm * 14.0]), Color("e5484d"))
		draw_colored_polygon(PackedVector2Array([p0, p1, tip - nrm * 14.0]), Color("e5484d"))
