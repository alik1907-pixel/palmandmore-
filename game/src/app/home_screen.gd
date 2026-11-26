extends Node2D
## Home: mascot (a live BalloonSim you can inflate), daily card, level grid,
## play button, and panels for balloons / themes / settings.

const W := 720.0
const H := 1280.0

var main: Node
var open_panel := ""
var buttons: Array = []
var mascot: BalloonSim
var mascot_hold := false
var pressed_id := ""
var t := 0.0
var sfx: Sfx
var toast := ""
var toast_t := 0.0
var grid_page := -1
const PAGE_SIZE := 15
const SKINS_PER_PAGE := 10
var skins_page := 0
var pending_buy := ""        # first tap selects a shop item, second tap confirms
const SET_STEP := 92.0      # settings rows (up to 9 rows must fit the panel)
const SET_H := 76.0

func _ready() -> void:
	sfx = Sfx.new()
	add_child(sfx)
	sfx.muted = not Profile.setting("sound")
	mascot = BalloonSim.new(_mascot_box())
	# open the grid on the page that holds the next level to play
	grid_page = (clampi(int(Profile.data.unlocked), 1, LevelBuilder.level_count()) - 1) / PAGE_SIZE
	Platform.rewarded_done.connect(_on_rewarded)
	Platform.purchase_done.connect(_on_purchase)
	Platform.prices_ready.connect(queue_redraw)
	Analytics.log_event("screen_home", {"stars": Profile.total_stars()})

func go_back() -> bool:
	## Returns true if handled (closed a panel); false means "leave the app".
	if open_panel == "lang":
		open_panel = "settings"
		return true
	if open_panel != "":
		open_panel = ""
		return true
	return false

func _mascot_box() -> Dictionary:
	var l := 230.0; var r := 490.0; var top := 210.0; var bot := 470.0
	return {"name": "", "hint": "", "start": Vector2(360, 400), "finish_y": -1e9, "overpop": false,
		"walls": [[Vector2(l, top), Vector2(r, top)], [Vector2(l, bot), Vector2(r, bot)], [Vector2(l, top), Vector2(l, bot)], [Vector2(r, top), Vector2(r, bot)]],
		"spikes": [], "winds": [], "gates": [], "bars": []}

func _style() -> ArtStyle:
	return main.style

func _physics_process(dt: float) -> void:
	t += dt
	var hold := mascot_hold
	if not mascot_hold:
		hold = mascot.center().y > 345.0 and mascot.velocity().y > -40.0   # idle: gentle bobbing
	mascot.step(hold)
	toast_t = maxf(toast_t - dt, 0.0)
	queue_redraw()

func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventScreenTouch):
		return
	var p: Vector2 = e.position
	if e.pressed:
		pressed_id = UI.hit(buttons, p)
		if pressed_id == "" and open_panel == "" and Rect2(200, 180, 320, 320).has_point(p):
			mascot_hold = true
		return
	mascot_hold = false
	var id := UI.hit(buttons, p)
	if id != "" and id == pressed_id:
		sfx.play("squeak", 1.4, -8.0)
		_on_button(id)
	pressed_id = ""

func _on_button(id: String) -> void:
	if id.begins_with("level:"):
		main.open_level(int(id.substr(6)))
		return
	if id.begins_with("skin:"):
		var s := id.substr(5)
		if Profile.data.owned_skins.has(s):
			Profile.set_skin(s)
			pending_buy = ""
			Analytics.log_event("skin_equip", {"skin": s})
		elif Skins.unlock_rule(s).has("coins"):
			if pending_buy != "skin:" + s:
				pending_buy = "skin:" + s
			elif Profile.buy_skin(s):
				pending_buy = ""
				sfx.play("win", 1.2)
				_toast(I18n.t("new_unlock"))
				Analytics.log_event("shop_buy", {"item": s, "price": int(Skins.unlock_rule(s).coins)})
			else:
				pending_buy = ""
				_toast(I18n.t("not_enough"))
		elif Skins.unlock_rule(s).has("ad"):
			Platform.show_rewarded("skin:" + s)
		elif Skins.unlock_rule(s).has("iap"):
			Platform.buy(Skins.unlock_rule(s).iap)
		return
	if id.begins_with("setlang:"):
		var code := id.substr(8)                     # "" = follow the system language
		Profile.data.settings.lang = code
		Profile.save()
		I18n.detect(code)
		Analytics.log_event("language", {"lang": I18n.lang, "auto": code == ""})
		open_panel = "settings"
		return
	if id.begins_with("style:"):
		var st := id.substr(6)
		if Profile.data.owned_styles.has(st):
			Profile.set_style(st)
			main.apply_style()
			pending_buy = ""
			Analytics.log_event("theme_equip", {"theme": st})
		elif ArtStyle.coin_price(st) > 0:
			if pending_buy != "style:" + st:
				pending_buy = "style:" + st
			elif Profile.buy_style(st):
				pending_buy = ""
				main.apply_style()
				sfx.play("win", 1.2)
				Analytics.log_event("shop_buy", {"item": st, "price": ArtStyle.coin_price(st)})
			else:
				pending_buy = ""
				_toast(I18n.t("not_enough"))
		return
	if id.begins_with("claim:"):
		var got := Profile.claim_mission(int(id.substr(6)))
		if got > 0:
			sfx.play("win", 1.1)
			_toast("+%d" % got)
			Analytics.log_event("mission_claim", {"reward": got})
		return
	match id:
		"play": main.open_level(clampi(int(Profile.data.unlocked), 1, LevelBuilder.level_count()))
		"daily":
			if Daily.pool_size() > 0:
				main.open_daily()
		"skins", "themes", "settings", "missions":
			open_panel = id
			pending_buy = ""
		"claim_bonus":
			var b := Profile.claim_bonus()
			if b > 0:
				sfx.play("win", 1.0)
				_toast("+%d" % b)
		"skins_prev": skins_page -= 1
		"skins_next": skins_page += 1
		"page_prev": grid_page -= 1
		"page_next": grid_page += 1
		"close": open_panel = ""
		"remove_ads", "theme_pack", "cosmetic_pack": Platform.buy(id)
		"restore": Platform.restore()
		"privacy": Platform.show_privacy_options()
		"policy": OS.shell_open(Platform.cfg.privacy_url)
		"sound":
			Profile.toggle_setting("sound")
			sfx.muted = not Profile.setting("sound")
		"music":
			Profile.toggle_setting("music")
			Music.enabled = Profile.setting("music")
		"haptics": Profile.toggle_setting("haptics")
		"text_size":
			var idx := (int(Profile.data.settings.get("text_scale", 0)) + 1) % UI.SCALES.size()
			Profile.data.settings.text_scale = idx
			Profile.save()
			main.apply_text_scale()
			Analytics.log_event("text_size", {"scale": UI.SCALES[idx]})
		"lang": open_panel = "lang"

func _on_rewarded(placement: String, ok: bool) -> void:
	if placement.begins_with("skin:") and ok:
		Profile.grant_skin(placement.substr(5))
		Profile.set_skin(placement.substr(5))
		_toast(I18n.t("new_unlock"))

func _on_purchase(product: String, ok: bool) -> void:
	if ok:
		_toast(I18n.t("new_unlock"))
		if product == "theme_pack":
			main.apply_style()

func _toast(s: String) -> void:
	toast = s
	toast_t = 2.0

# ------------------------------------------------------------------ draw
func _draw() -> void:
	buttons.clear()
	var st := _style()
	var ink: Color = st.c.ui
	# top bar
	UI.star(self, Vector2(56, 70), 24.0, true)
	UI.text_left(self, str(Profile.total_stars()), Vector2(90, 84), 40, ink, 120.0)
	UI.icon(self, "coin", Vector2(232, 70), 22.0, Color.WHITE)
	UI.text_left(self, str(Profile.coins()), Vector2(262, 84), 40, ink, 140.0)
	_btn("settings", Rect2(W - 112, 30, 80, 80), "", false)
	UI.icon(self, "gear", Vector2(W - 72, 70), 26.0, Color.WHITE)
	# title + mascot
	UI.text_center(self, "ŞİŞ", Vector2(W * 0.5, 190), 110, ink)
	_draw_mascot(st)
	# daily card
	var dr := Rect2(60, 520, W - 120, 120)
	_btn("daily", dr, "", false)
	UI.icon(self, "calendar", Vector2(120, 580), 26.0, Color.WHITE)
	var done := int(Profile.data.last_daily) == Profile.today()
	UI.text_left(self, "%s #%d" % [I18n.t("daily"), Daily.number_for(Profile.today())], Vector2(170, 572), 32, Color.WHITE, W - 170.0 - 190.0)
	UI.text_left(self, I18n.t("daily_done") if done else "", Vector2(170, 614), 24, Color(1, 1, 1, 0.85), W - 170.0 - 190.0)
	UI.icon(self, "flame", Vector2(W - 150, 578), 26.0, Color.WHITE)
	UI.text_left(self, str(Profile.streak_alive()), Vector2(W - 118, 592), 36, Color.WHITE)
	# level grid: pages of 15 (5x3), page arrows at the sides
	var n := LevelBuilder.level_count()
	var pages := maxi(ceili(n / float(PAGE_SIZE)), 1)
	grid_page = clampi(grid_page, 0, pages - 1)
	var first := grid_page * PAGE_SIZE
	for i in range(first, mini(first + PAGE_SIZE, n)):
		var k := i - first
		var r := Rect2(54 + (k % 5) * 126, 672 + (k / 5) * 122, 108, 108)
		var lvl := i + 1
		var open := lvl <= int(Profile.data.unlocked)
		UI.panel(self, r, st, 0.9 if open else 0.45)
		if open:
			buttons.append({"id": "level:%d" % lvl, "rect": r})
			UI.text_center(self, str(lvl), r.get_center() + Vector2(0, 4), 40, ink)
			for s_i in 3:
				UI.star(self, r.position + Vector2(28 + s_i * 26, 86), 10.0, s_i < Profile.stars_of(lvl))
		else:
			UI.icon(self, "lock", r.get_center(), 22.0, Color(ink, 0.5))
	if pages > 1:
		if grid_page > 0:
			_arrow("page_prev", Rect2(4, 790, 46, 110), -1.0, ink)
		if grid_page < pages - 1:
			_arrow("page_next", Rect2(W - 50, 790, 46, 110), 1.0, ink)
		if pages <= 8:
			for p_i in pages:
				draw_circle(Vector2(W * 0.5 + (p_i - (pages - 1) * 0.5) * 22.0, 1030), 5.0, Color(ink, 0.85 if p_i == grid_page else 0.25))
		else:   # endless campaign: show the level range instead of ~130 dots
			UI.text_center(self, "%d–%d" % [first + 1, mini(first + PAGE_SIZE, n)], Vector2(W * 0.5, 1040), 22, Color(ink, 0.6), 200.0)
	# play
	_btn("play", Rect2(140, 1050, W - 280, 104), I18n.t("play"), true)
	# bottom row: balloons, themes, missions (+badge), remove ads
	var ids := ["skins", "themes", "missions"]
	if not Profile.data.ads_removed:
		ids.append("remove_ads")
	var icons := {"skins": "balloon", "themes": "palette", "missions": "list", "remove_ads": "noads"}
	var span := 600.0 / ids.size()
	for i in ids.size():
		var cx := 60.0 + span * (i + 0.5)
		_btn(ids[i], Rect2(cx - 56, 1172, 112, 84), "", false)
		UI.icon(self, icons[ids[i]], Vector2(cx, 1214 - (4 if ids[i] == "skins" else 0)), 26.0, Color.WHITE)
		if ids[i] == "missions":
			var badge := Profile.claimable_count()
			if badge > 0:
				draw_circle(Vector2(cx + 44, 1178), 18.0, Color("e8553e"))
				UI.text_center(self, str(badge), Vector2(cx + 44, 1188), 24, Color.WHITE, 40.0)
	if open_panel != "":
		buttons.clear()     # modal: only panel buttons are live
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.45))
		match open_panel:
			"skins": _draw_skins(st)
			"missions": _draw_missions(st)
			"themes": _draw_themes(st)
			"settings": _draw_settings(st)
			"lang": _draw_languages(st)
	if toast_t > 0.0:
		var a := clampf(toast_t, 0.0, 1.0)
		UI._round_rect(self, Rect2(160, 110, 400, 70), 30.0, Color(0, 0, 0, 0.7 * a))
		UI.text_center(self, toast, Vector2(360, 156), 34, Color(1, 1, 1, a))

func _arrow(id: String, r: Rect2, dir: float, col: Color) -> void:
	var c := r.get_center()
	draw_colored_polygon(PackedVector2Array([c + Vector2(-10 * dir, -22), c + Vector2(12 * dir, 0), c + Vector2(-10 * dir, 22)]), Color(col, 0.75))
	buttons.append({"id": id, "rect": r})

func _btn(id: String, r: Rect2, label: String, primary: bool, enabled := true) -> void:
	UI.button(self, r, label, _style(), primary, enabled, pressed_id == id)
	buttons.append({"id": id, "rect": r, "enabled": enabled})

func _balloon_preview(c: Vector2, r: float, skin: String, st: ArtStyle) -> void:
	var body := PackedVector2Array()
	for i in 28:
		body.append(c + Vector2.from_angle(TAU * i / 28.0) * r)
	draw_colored_polygon(body, Skins.base_color(skin, st))
	Skins.draw_pattern(self, skin, body, c, r, t)
	draw_arc(c + Vector2(-r * 0.15, -r * 0.2), r * 0.62, PI * 1.05, PI * 1.45, 10, Color(1, 1, 1, 0.5), r * 0.12)
	for sx in [-1.0, 1.0]:
		draw_circle(c + Vector2(sx * r * 0.32, -r * 0.1), r * 0.18, Color.WHITE)
		draw_circle(c + Vector2(sx * r * 0.32, -r * 0.06), r * 0.09, st.c.ink)
	draw_arc(c + Vector2(0, r * 0.25), r * 0.14, 0.4, PI - 0.4, 8, st.c.ink, 3.0)

const MASCOT_SCALE := 1.6
const MASCOT_PIVOT := Vector2(360, 340)

func _draw_mascot(st: ArtStyle) -> void:
	# draw the live sim scaled up around the jar centre
	draw_set_transform(MASCOT_PIVOT * (1.0 - MASCOT_SCALE), 0.0, Vector2.ONE * MASCOT_SCALE)
	_draw_mascot_body(st)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_mascot_body(st: ArtStyle) -> void:
	var pts := PackedVector2Array()
	var off := Vector2(0, 0)
	for p in mascot.pos:
		pts.append(p + off)
	var skin := String(Profile.data.skin)
	var col := Skins.base_color(skin, st)
	if Geometry2D.triangulate_polygon(pts).is_empty():
		return
	draw_colored_polygon(pts, col)
	var c := mascot.center() + off
	var r := mascot.radius()
	Skins.draw_pattern(self, skin, pts, c, r, t)
	var o := pts.duplicate(); o.append(pts[0])
	draw_polyline(o, col.darkened(0.35), 4.0, true)
	draw_arc(c + Vector2(-r * 0.15, -r * 0.2), r * 0.62, PI * 1.05, PI * 1.45, 10, Color(1, 1, 1, 0.5), r * 0.12)
	for sx in [-1.0, 1.0]:
		draw_circle(c + Vector2(sx * r * 0.32, -r * 0.1), r * 0.2, Color.WHITE)
		draw_circle(c + Vector2(sx * r * 0.32, -r * 0.05), r * 0.1, st.c.ink)
	draw_arc(c + Vector2(0, r * 0.25), r * 0.15, 0.4, PI - 0.4, 8, st.c.ink, 3.0)
	draw_line(c + Vector2(0, r), c + Vector2(6 * sin(t * 2.0), r + 46), st.c.ink, 2.0)

func _panel_frame(st: ArtStyle, title: String) -> Rect2:
	var r := Rect2(40, 150, W - 80, 980)
	UI.panel(self, r, st, 0.98)
	var ink: Color = st.c.ink if st.id != "gece" else Color.WHITE
	UI.text_center(self, title, Vector2(W * 0.5, r.position.y + 76), 44, ink)
	_btn("close", Rect2(r.end.x - 100, r.position.y + 20, 76, 76), "×", false)
	return r

func _draw_skins(st: ArtStyle) -> void:
	var r := _panel_frame(st, I18n.t("skins"))
	var ink: Color = st.c.ink if st.id != "gece" else Color.WHITE
	var pages := ceili(Skins.ALL.size() / float(SKINS_PER_PAGE))
	skins_page = clampi(skins_page, 0, pages - 1)
	UI.icon(self, "coin", Vector2(r.position.x + 50, r.position.y + 62), 18.0, Color.WHITE)
	UI.text_left(self, str(Profile.coins()), Vector2(r.position.x + 76, r.position.y + 74), 30, ink, 140.0)
	for i in range(skins_page * SKINS_PER_PAGE, mini((skins_page + 1) * SKINS_PER_PAGE, Skins.ALL.size())):
		var s: String = Skins.ALL[i]
		var k := i - skins_page * SKINS_PER_PAGE
		var cell := Rect2(r.position.x + 30 + (k % 2) * 310, r.position.y + 120 + (k / 2) * 160, 290, 146)
		var owned: bool = Profile.data.owned_skins.has(s)
		var sel: bool = String(Profile.data.skin) == s
		UI._round_rect(self, cell, 22.0, Color(st.c.finish, 0.35) if sel else Color(0, 0, 0, 0.06))
		_balloon_preview(cell.position + Vector2(75, 75), 48.0, s, st)
		var rule := Skins.unlock_rule(s)
		var label := ""
		if owned:
			label = "✓" if sel else ""
		elif rule.has("stars"):
			label = I18n.t("locked_stars") % rule.stars
		elif rule.has("streak"):
			label = I18n.t("locked_streak") % rule.streak
		elif rule.has("ad"):
			label = I18n.t("watch_unlock")
		elif rule.has("iap"):
			label = Platform.price_of(rule.iap) if Platform.price_of(rule.iap) != "" else I18n.t("cosmetic_pack")
		elif rule.has("coins"):
			label = (I18n.t("buy_confirm") % rule.coins) if pending_buy == "skin:" + s else str(rule.coins)
			if pending_buy == "skin:" + s:
				UI._round_rect(self, cell.grow(-3), 20.0, Color(st.c.finish, 0.25))
			else:
				UI.icon(self, "coin", cell.position + Vector2(150, 72), 14.0, Color.WHITE)
		var enabled: bool = owned or rule.has("ad") or rule.has("iap") or rule.has("coins")
		if rule.has("ad") and not owned and not Platform.rewarded_available():
			enabled = false
		buttons.append({"id": "skin:" + s, "rect": cell, "enabled": enabled})
		if rule.has("ad") and not owned:
			UI.icon(self, "film", cell.position + Vector2(158, 46), 16.0, ink)
		var lx := 172.0 if (rule.has("coins") and not owned and pending_buy != "skin:" + s) else 136.0
		UI.text_wrap(self, label, cell.position + Vector2(lx, 82), cell.size.x - lx - 10.0, 20, ink)
	if pages > 1:
		if skins_page > 0:
			_arrow("skins_prev", Rect2(r.position.x + 6, r.end.y - 70, 60, 60), -1.0, ink)
		if skins_page < pages - 1:
			_arrow("skins_next", Rect2(r.end.x - 66, r.end.y - 70, 60, 60), 1.0, ink)
		for p_i in pages:
			draw_circle(Vector2(W * 0.5 + (p_i - (pages - 1) * 0.5) * 22.0, r.end.y - 40), 5.0, Color(ink, 0.85 if p_i == skins_page else 0.25))

func _draw_themes(st: ArtStyle) -> void:
	var r := _panel_frame(st, I18n.t("themes"))
	var ink: Color = st.c.ink if st.id != "gece" else Color.WHITE
	for i in ArtStyle.IDS.size():
		var id: String = ArtStyle.IDS[i]
		var s := ArtStyle.make(id)
		var cell := Rect2(r.position.x + 30, r.position.y + 130 + i * 220, r.size.x - 60, 200)
		var owned: bool = Profile.data.owned_styles.has(id)
		var top: Color = s.bg.top_color
		var bot: Color = s.bg.bottom_color
		draw_polygon(PackedVector2Array([cell.position, Vector2(cell.end.x, cell.position.y), cell.end, Vector2(cell.position.x, cell.end.y)]),
			PackedColorArray([top, top, bot, bot]))
		s.draw_wall(self, cell.position + Vector2(40, 150), cell.position + Vector2(200, 80))
		s.draw_spikes(self, cell.position + Vector2(260, 160), cell.position + Vector2(420, 160))
		_balloon_preview(cell.position + Vector2(cell.size.x - 110, 95), 50.0, "classic", s)
		UI.text_left(self, I18n.t("theme_" + id) + ("  ✓" if String(Profile.data.style) == id else ""), cell.position + Vector2(24, 50), 30, s.c.ui)
		if not owned:
			var price := ArtStyle.coin_price(id)
			var line := I18n.t("locked_stars") % ArtStyle.unlock_stars(id)
			if price > 0:
				line += "   ·   " + ((I18n.t("buy_confirm") % price) if pending_buy == "style:" + id else "%d" % price)
			UI.text_left(self, line, cell.position + Vector2(24, 190), 22, s.c.ui, cell.size.x - 70.0)
			if price > 0 and pending_buy != "style:" + id:
				var size := UI.fit(line, UI.scaled(22), cell.size.x - 70.0)
				var wpx := UI.f().get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
				UI.icon(self, "coin", cell.position + Vector2(24 + wpx + 18, 183), 12.0, Color.WHITE)
		buttons.append({"id": "style:" + id, "rect": cell, "enabled": owned or ArtStyle.coin_price(id) > 0})
	if Platform.can_buy("theme_pack") or OS.is_debug_build():
		var price := Platform.price_of("theme_pack")
		_btn("theme_pack", Rect2(r.position.x + 60, r.end.y - 140, r.size.x - 120, 96), I18n.t("theme_pack") + ("  " + price if price != "" else ""), true)

func _draw_settings(st: ArtStyle) -> void:
	var r := _panel_frame(st, I18n.t("settings"))
	var y := r.position.y + 140
	for k in ["sound", "music", "haptics"]:
		_btn(k, Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), "%s: %s" % [I18n.t(k), "✓" if Profile.setting(k) else "—"], false)
		y += SET_STEP
	_btn("lang", Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), "%s: %s" % [I18n.t("language"), I18n.lang_name(I18n.lang)], false)
	y += SET_STEP
	var ts := clampi(int(Profile.data.settings.get("text_scale", 0)), 0, UI.SCALES.size() - 1)
	_btn("text_size", Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), "%s: %s" % [I18n.t("text_size"), I18n.t(UI.SCALE_KEYS[ts])], false)
	y += SET_STEP
	if not Profile.data.ads_removed:
		var price := Platform.price_of("remove_ads")
		_btn("remove_ads", Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), I18n.t("remove_ads") + ("  " + price if price != "" else ""), true)
		y += SET_STEP
	_btn("restore", Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), I18n.t("restore"), false)
	y += SET_STEP
	if Platform.privacy_options_available():
		_btn("privacy", Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), I18n.t("privacy"), false)
		y += SET_STEP
	_btn("policy", Rect2(r.position.x + 60, y, r.size.x - 120, SET_H), I18n.t("privacy_policy"), false)

func _draw_languages(st: ArtStyle) -> void:
	var r := _panel_frame(st, I18n.t("language"))
	var ink: Color = st.c.ink if st.id != "gece" else Color.WHITE
	var saved := String(Profile.data.settings.get("lang", ""))
	var codes: Array = [""]
	codes.append_array(Array(I18n.langs()))
	var col_w := (r.size.x - 90.0) * 0.5
	for i in codes.size():
		var code: String = codes[i]
		var cell := Rect2(r.position.x + 30 + (i % 2) * (col_w + 30), r.position.y + 120 + (i / 2) * 102, col_w, 86)
		var label := ("⟳ " + OS.get_locale_language().to_upper()) if code == "" else I18n.lang_name(code)
		var selected := saved == code
		_btn("setlang:" + code, cell, "", false)
		if selected:
			UI._round_rect(self, cell.grow(-6), 18.0, Color(1, 1, 1, 0.25))
		UI.text_center(self, label + ("  ✓" if selected else ""), cell.get_center() + Vector2(0, 11), 28, Color.WHITE)

func _draw_missions(st: ArtStyle) -> void:
	var r := _panel_frame(st, I18n.t("missions"))
	var ink: Color = st.c.ink if st.id != "gece" else Color.WHITE
	var list := Profile.missions_today()
	for i in list.size():
		var mi: Dictionary = list[i]
		var row := Rect2(r.position.x + 30, r.position.y + 130 + i * 190, r.size.x - 60, 170)
		UI._round_rect(self, row, 22.0, Color(0, 0, 0, 0.06))
		var key := "mission_" + String(mi.type)
		var text := I18n.t(key) % int(mi.target) if I18n.t(key).contains("%d") else I18n.t(key)
		UI.text_left(self, text, row.position + Vector2(24, 50), 28, ink, row.size.x - 48.0)
		var bar := Rect2(row.position + Vector2(24, 76), Vector2(row.size.x - 220, 22))
		UI._round_rect(self, bar, 11.0, Color(ink, 0.15))
		var k := clampf(float(mi.progress) / maxf(float(mi.target), 1.0), 0.0, 1.0)
		if k > 0.0:
			UI._round_rect(self, Rect2(bar.position, Vector2(maxf(bar.size.x * k, 22.0), bar.size.y)), 11.0, st.c.finish)
		UI.text_left(self, "%d / %d" % [int(mi.progress), int(mi.target)], row.position + Vector2(24, 140), 24, Color(ink, 0.7))
		UI.icon(self, "coin", row.position + Vector2(row.size.x - 170, 88), 16.0, Color.WHITE)
		UI.text_left(self, "+%d" % int(mi.reward), row.position + Vector2(row.size.x - 148, 100), 28, ink, 120.0)
		if mi.claimed:
			UI.text_left(self, "✓", row.position + Vector2(row.size.x - 70, 150), 40, st.c.finish)
		elif Profile.mission_done(mi):
			_btn("claim:%d" % i, Rect2(row.position + Vector2(row.size.x - 180, 112), Vector2(160, 50)), I18n.t("claim"), true)
	var by := r.position.y + 130 + 3 * 190 + 10
	if Profile.bonus_available():
		_btn("claim_bonus", Rect2(r.position.x + 60, by, r.size.x - 120, 84), I18n.t("all_done_bonus") % Profile.MISSION_BONUS, true)
	else:
		UI.text_center(self, I18n.t("all_done_bonus") % Profile.MISSION_BONUS, Vector2(W * 0.5, by + 50), 26, Color(ink, 0.55), r.size.x - 80.0)
	var secs_left := 86400 - int(fposmod(Time.get_unix_time_from_system() + float(Time.get_time_zone_from_system().bias) * 60.0, 86400.0))
	UI.text_center(self, I18n.t("new_missions_in") % maxi(1, ceili(secs_left / 3600.0)), Vector2(W * 0.5, r.end.y - 40), 24, Color(ink, 0.6), r.size.x - 80.0)
