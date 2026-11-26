extends Node2D
## Greybox renderer for DALGA. Tap water to drop a stone.
## `-- autoplay <level> <skill> <seed>` for bot/video.

var sim: DalSim
var bot: DalBot = null
var level_index := 0
var splashes: Array = []
var img: Image
var tex: ImageTexture

func _ready() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() >= 1 and a[0] == "autoplay":
		level_index = int(a[1])
	sim = DalSim.new(DalLevels.make(level_index))
	if a.size() >= 1 and a[0] == "autoplay":
		bot = DalBot.new(float(a[2]) if a.size() > 2 else 1.0, int(a[3]) if a.size() > 3 else 1, sim)
	img = Image.create(DalSim.GW, DalSim.GH, false, Image.FORMAT_RGB8)
	tex = ImageTexture.create_from_image(img)

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch and e.pressed:
		if sim.state != "play":
			if sim.state == "won": level_index += 1
			sim = DalSim.new(DalLevels.make(level_index))
			return
		_drop(e.position)

func _drop(p: Vector2) -> void:
	var before := sim.stones
	sim.drop(p)
	if sim.stones < before:
		splashes.append({"p": p, "t": 0.0})

func _physics_process(_dt: float) -> void:
	if bot != null and sim.state == "play":
		var p = bot.decide(sim)
		if p != null: _drop(p)
	sim.step()
	for s in splashes: s.t += 1.0 / 60.0
	splashes = splashes.filter(func(s): return s.t < 1.2)
	queue_redraw()

func _draw() -> void:
	var deep := Color("0b2a3c"); var crest := Color("7fd6e6"); var trough := Color("041621")
	for y in DalSim.GH:
		for x in DalSim.GW:
			var i := y * DalSim.GW + x
			if sim.wall[i] == 1:
				img.set_pixel(x, y, Color("2a2f36"))
			else:
				var v: float = clamp(sim.h[i] / 3.0, -1.0, 1.0)
				img.set_pixel(x, y, deep.lerp(crest, v) if v > 0.0 else deep.lerp(trough, -v))
	tex.update(img)
	draw_texture_rect(tex, Rect2(0, 0, 720, 1280), false)
	draw_arc(sim.goal, DalSim.GOAL_R, 0, TAU, 40, Color("ffd27a"), 4.0)
	draw_circle(sim.goal, 10.0, Color("ffd27a"))
	for s in splashes:
		draw_arc(s.p, 10.0 + s.t * 160.0, 0, TAU, 32, Color(1, 1, 1, 1.0 - s.t / 1.2), 3.0)
	var lc := Color("ff9f43") if sim.state != "lost" else Color("555555")
	draw_circle(sim.lantern, 18.0, lc)
	draw_circle(sim.lantern, 8.0, Color("fff3c4"))
	draw_string(ThemeDB.fallback_font, Vector2(40, 70), "DALGA • Bölüm %d   Taş: %d" % [level_index + 1, sim.stones], HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color.WHITE)
	var msg := ""
	if sim.state == "won": msg = "LİMANDA!"
	elif sim.reason == "capsized": msg = "DEVRİLDİ"
	elif sim.state == "lost": msg = "TAŞ BİTTİ"
	if msg != "":
		draw_string(ThemeDB.fallback_font, Vector2(0, 640), msg, HORIZONTAL_ALIGNMENT_CENTER, 720, 64, Color.WHITE)
