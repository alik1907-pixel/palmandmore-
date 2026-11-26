extends Node
## Root: owns the themed background and swaps screens (home ↔ game).
## CLI (QA/video/store shots):
##   -- autoplay <level> <skill> <seed> <levels>     bot plays from <level>
##   -- shot <home|skins|themes|settings|daily>       opens a screen for capture
##   -- style <kagit|gece|pastel>                     temporary theme override

const GameScreenScript := preload("res://src/game/game_screen.gd")
const HomeScreenScript := preload("res://src/app/home_screen.gd")

var style: ArtStyle
var bg_mat: ShaderMaterial
var screen: Node = null
var attempts := {}
var cli := {}

func _ready() -> void:
	_parse_cli()
	if cli.has("demo"):
		_demo_profile()
	I18n.detect(String(cli.get("lang", Profile.data.settings.get("lang", ""))))
	apply_text_scale()
	var layer := CanvasLayer.new()
	layer.layer = -1
	add_child(layer)
	var rect := ColorRect.new()
	rect.size = Vector2(720, 1280)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_mat = ShaderMaterial.new()
	bg_mat.shader = preload("res://src/art/bg.gdshader")
	rect.material = bg_mat
	layer.add_child(rect)
	apply_style()
	Music.enabled = Profile.setting("music")
	if cli.has("autoplay"):
		var a: Array = cli.autoplay
		open_level(int(a[0]), {"skill": float(a[1]), "seed": int(a[2]), "count": int(a[3])})
	elif cli.has("selftest"):
		open_home()
		_selftest()
	elif cli.has("shot"):
		open_home(String(cli.shot))
	else:
		open_home()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:      # Android back button
		if screen != null and screen.has_method("go_back"):
			var handled = screen.go_back()
			if handled == false:
				quit_clean()
		else:
			quit_clean()

## Frees audio-playing nodes and gives the audio server a moment before quitting
## (avoids dangling playbacks at exit).
func quit_clean() -> void:
	Analytics.flush()
	if screen != null:
		screen.queue_free()
		screen = null
	Music.queue_free()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()

func _parse_cli() -> void:
	var a := OS.get_cmdline_user_args()
	var i := 0
	while i < a.size():
		match a[i]:
			"autoplay":
				cli.autoplay = [a[i + 1], a[i + 2], a[i + 3], a[i + 4]]
				i += 4
			"shot":
				cli.shot = a[i + 1]
				i += 1
			"style":
				cli.style = a[i + 1]
				i += 1
			"demo":
				cli.demo = true
			"selftest":
				cli.selftest = true
			"textscale":
				cli.textscale = a[i + 1]
				i += 1
			"unlock":
				cli.unlock = int(a[i + 1])
				i += 1
			"coins":
				cli.coins = int(a[i + 1])
				i += 1
			"lang":
				cli.lang = a[i + 1]
				i += 1
		i += 1

func apply_text_scale() -> void:
	var idx := clampi(int(Profile.data.settings.get("text_scale", 0)), 0, UI.SCALES.size() - 1)
	if cli.has("textscale"):
		idx = clampi(int(cli.textscale), 0, UI.SCALES.size() - 1)
	UI.scale = UI.SCALES[idx]

func apply_style() -> void:
	style = ArtStyle.make(String(cli.get("style", Profile.data.style)))
	style.apply_background(bg_mat)

func set_scroll(y: float) -> void:
	bg_mat.set_shader_parameter("scroll", y)

func _swap(next: Node) -> void:
	if screen != null:
		screen.queue_free()
	screen = next
	add_child(next)

func open_home(panel := "") -> void:
	var h = HomeScreenScript.new()
	h.main = self
	h.open_panel = "" if panel == "home" else panel
	if panel.begins_with("skins") and panel.length() > 5:     # "skins2" → shop page 2 (store shots)
		h.open_panel = "skins"
		h.skins_page = int(panel.substr(5)) - 1
	Music.set_mood(0.0, 0.0, false)
	_swap(h)

func open_level(n: int, auto := {}) -> void:
	n = clampi(n, 1, LevelBuilder.level_count())     # never open a missing level
	var g = GameScreenScript.new()
	g.main = self
	g.mode = "level"
	g.level_num = n
	g.level = LevelBuilder.load_level(n)
	g.auto = auto
	attempts[n] = int(attempts.get(n, 0)) + 1
	g.attempt = attempts[n]
	_swap(g)

func open_daily(auto := {}) -> void:
	var g = GameScreenScript.new()
	g.main = self
	g.mode = "daily"
	g.level_num = Daily.number_for(Profile.today())
	g.level = Daily.level_for(Profile.today())
	g.auto = auto
	_swap(g)

func next_level_after(n: int) -> int:
	return mini(n + 1, LevelBuilder.level_count())

## Store-screenshot state: mid-game progress, kept in memory only (never saved).
func _demo_profile() -> void:
	var d: Dictionary = Profile.data
	d.unlocked = int(cli.get("unlock", 10))
	for i in range(1, int(d.unlocked)):
		d.stars[str(i)] = 3 if i % 3 != 0 else 2
	d.streak = 5
	d.best_streak = 5
	d.last_daily = Profile.today() - 1
	d.owned_skins = ["classic", "stripes", "dots", "melon", "stars", "ghost"]
	d.skin = "stripes"
	d.owned_styles = ["kagit", "gece"]
	d.coins = int(cli.get("coins", 740))

# ------------------------------------------------------------------ QA
## Taps the centre of a button the current screen drew last frame (by id), so the
## walk survives layout changes. Missing ids are reported as failed steps.
func _tap_id(id: String, hold_s := 0.08) -> void:
	await get_tree().process_frame
	for b in screen.get("buttons"):
		if b.id == id:
			await _tap((b.rect as Rect2).get_center(), hold_s)
			return
	print("SELFTEST missing button: ", id)

func _tap(p: Vector2, hold_s := 0.08) -> void:
	var d := InputEventScreenTouch.new()
	d.position = p
	d.pressed = true
	get_viewport().push_input(d, true)
	await get_tree().create_timer(hold_s).timeout
	var u := InputEventScreenTouch.new()
	u.position = p
	u.pressed = false
	get_viewport().push_input(u, true)
	await get_tree().create_timer(0.25).timeout

## End-to-end UI walk with synthetic touches. Prints SELFTEST lines; any
## SCRIPT ERROR in the log fails it. Never saves the real profile.
func _selftest() -> void:
	Profile.persist = false
	var steps: Array[String] = []
	await get_tree().create_timer(0.5).timeout
	print("SELFTEST start screen=", screen.get_script().resource_path)
	await _tap_id("play")                          # PLAY → level 1
	print("SELFTEST after play screen=", screen.get_script().resource_path)
	steps.append("open_level:%s" % (screen.get("mode") == "level"))
	await _tap(Vector2(360, 900), 1.6)             # hold to inflate
	await get_tree().create_timer(1.0).timeout
	await _tap_id("home")                          # home button
	steps.append("back_home:%s" % (screen.get("open_panel") != null))
	for id in ["skins", "themes", "missions", "settings"]:
		await _tap_id(id)                          # panels
		steps.append("panel:%s" % screen.get("open_panel"))
		print("SELFTEST ", steps[-1])
		notification(NOTIFICATION_WM_GO_BACK_REQUEST)   # back closes the panel
		await get_tree().create_timer(0.2).timeout
	await _tap_id("skins")                         # shop paging + two-tap purchase guard
	await _tap_id("skins_next")
	steps.append("skins_page:%s" % (screen.get("skins_page") == 1))
	notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().create_timer(0.2).timeout
	await _tap_id("settings")                      # settings → language panel
	await _tap_id("lang")
	steps.append("lang_panel:%s" % (screen.get("open_panel") == "lang"))
	await _tap_id("setlang:en")                    # English
	steps.append("lang_en:%s" % (I18n.lang == "en"))
	await _tap_id("lang")
	await _tap_id("setlang:ja")                    # 日本語
	steps.append("lang_ja:%s" % (I18n.lang == "ja"))
	await _tap_id("lang")
	await _tap_id("setlang:")                      # follow system
	steps.append("lang_auto:%s" % (String(Profile.data.settings.lang) == ""))
	notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().create_timer(0.2).timeout
	var page0: int = screen.get("grid_page")
	await _tap_id("page_next")                     # level grid: next page
	steps.append("page_next:%s" % (screen.get("grid_page") == page0 + 1))
	await _tap_id("page_prev")                     # previous page
	steps.append("page_prev:%s" % (screen.get("grid_page") == page0))
	await _tap_id("daily")                         # daily card
	steps.append("open_daily:%s" % (screen.get("mode") == "daily"))
	await _tap(Vector2(360, 900), 1.0)
	notification(NOTIFICATION_WM_GO_BACK_REQUEST)  # back from game → home
	await get_tree().create_timer(0.3).timeout
	steps.append("daily_back_home:%s" % (screen.get("open_panel") != null))
	print("SELFTEST ", " ".join(steps))
	print("SELFTEST_DONE")
	quit_clean()

const W_SET := Vector2(648, 70)
const W_ARROW_NEXT := Vector2(693, 845)
