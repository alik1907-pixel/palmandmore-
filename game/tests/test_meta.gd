extends TestCase
## Meta systems: daily pool, profile rules, i18n coverage, cosmetics, config.

func test_daily_pool_integrity() -> void:
	assert_true(Daily.pool_size() >= 30, "pool size %d" % Daily.pool_size())
	var d := 20900
	var a := Daily.level_for(d)
	var b := Daily.level_for(d)
	assert_eq(a.walls.size(), b.walls.size(), "same day → same level")
	assert_eq(a.finish_y, b.finish_y)
	var c := Daily.level_for(d + 1)
	assert_true(a.finish_y != c.finish_y or a.walls.size() != c.walls.size(), "next day differs")
	assert_eq(Daily.number_for(Daily.LAUNCH_DAY), 1)

func test_daily_sample_solvable() -> void:
	for k in [0, 17, 41]:
		var lvl := Daily.level_for(k)
		seed(k)
		var sim := BalloonSim.new(lvl)
		var bot := BalloonPlanner.new(1.0, k)
		while sim.state == "play" and sim.frame < 60 * 60:
			sim.step(bot.decide(sim))
		assert_eq(sim.state, "won", "daily pool entry %d" % k)

func _profile() -> Node:
	var p: Node = load("res://src/core/profile.gd").new()
	p.persist = false
	p.data = p._defaults()
	return p

func test_profile_stars_unlock_and_records() -> void:
	var p := _profile()
	var r: Dictionary = p.record_level(1, 2, 12.5)
	assert_eq(p.stars_of(1), 2)
	assert_eq(int(p.data.unlocked), 2)
	p.record_level(1, 1, 30.0)
	assert_eq(p.stars_of(1), 2, "stars never go down")
	assert_eq(float(p.data.best_time["1"]), 12.5, "slower run keeps best")
	p.record_level(2, 1, 9999.0)
	assert_true(not p.data.best_time.has("2"), "assisted run sets no record")
	for lvl in range(1, 7):
		p.record_level(lvl, 3, 10.0)
	assert_true(p.data.owned_skins.has("stripes"), "6 stars unlock stripes")
	p.free()

func test_profile_streak_rules() -> void:
	var p := _profile()
	var today: int = p.today()
	p.data.last_daily = today - 1
	p.data.streak = 3
	p.record_daily(20.0)
	assert_eq(int(p.data.streak), 4, "consecutive day extends")
	p.record_daily(18.0)
	assert_eq(int(p.data.streak), 4, "same day twice does not double count")
	p.data.last_daily = today - 3
	p.record_daily(20.0)
	assert_eq(int(p.data.streak), 1, "missed days reset")
	p.free()

func test_i18n_complete() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(I18n.PATH))
	var langs: Array = d._langs
	assert_true(langs.size() >= 15, "language count %d" % langs.size())
	assert_true(langs.has("en"), "English present")
	for key in d.strings:
		var row: Dictionary = d.strings[key]
		for lang in langs:
			assert_true(row.has(lang) and String(row[lang]).strip_edges() != "", "%s missing %s" % [key, lang])
			if row.has(lang):
				var txt: String = row[lang]
				assert_eq(txt.count("%d"), String(row.en).count("%d"), "%s/%s %%d count" % [key, lang])
				assert_eq(txt.count("%s"), String(row.en).count("%s"), "%s/%s %%s count" % [key, lang])
	for n in range(1, I18n.FIRST_WORLD_LEVEL):
		assert_true(d.strings.has("level_%d" % n), "level %d name" % n)
	for w in range(1, I18n.WORLD_NAMES + 1):
		assert_true(d.strings.has("world_%d" % w), "world %d name" % w)
	I18n.set_lang("en")
	assert_eq(I18n.level_name(16), "Wind Valley")
	assert_eq(I18n.level_name(50), "Last Breath")
	assert_eq(I18n.level_name(51), "Wind Valley 2", "worlds repeat with a tier number")
	assert_eq(I18n.level_name(16 + 5 * 7 * 2), "Wind Valley 3")
	for st in ArtStyle.IDS:
		assert_true(d.strings.has("theme_" + st), "theme name " + st)

func test_i18n_fallback_and_formatting() -> void:
	I18n.set_lang("xx")
	assert_eq(I18n.lang, "en", "unknown language falls back to English")
	for lang in I18n.langs():
		I18n.set_lang(lang)
		var a: String = I18n.t("share_level") % [3, "12.5", "⭐⭐"]
		var b: String = I18n.t("share_daily") % [7, "20.1", "⭐", 4]
		var c: String = I18n.t("locked_stars") % 25
		assert_true(a.contains("3") and b.contains("7") and c.contains("25"), "format " + lang)
	I18n.set_lang("en")
	assert_eq(I18n.level_name(1), "First Breath")

func test_skins_and_styles_have_rules() -> void:
	for s in Skins.ALL:
		assert_true(not Skins.unlock_rule(s).is_empty(), "rule for " + s)
	for st in ArtStyle.IDS:
		assert_eq(ArtStyle.make(st).id, st)

func test_platform_config() -> void:
	var c := PlatformConfig.load_config()
	assert_true(c.admob_app_id.begins_with("ca-app-pub-"))
	assert_true(c.products.has("remove_ads"))
	assert_true(c.firebase.has("app_id") and c.firebase.has("sender_id"), "firebase block present")

func test_firebase_gating() -> void:
	var c := PlatformConfig.new()
	assert_true(not c.firebase_enabled(), "empty config → Firebase not packaged")
	c.firebase = {"app_id": "1:1:android:1", "api_key": "k", "project_id": "p", "sender_id": "1"}
	assert_true(c.firebase_enabled())
	c.firebase.api_key = ""
	assert_true(not c.firebase_enabled(), "partial config stays disabled")

func test_text_scale_fit() -> void:
	var long := "Политика конфиденциальности и ещё очень длинный текст"
	for sc in UI.SCALES:
		UI.scale = sc
		var size := UI.fit(long, UI.scaled(30), 480.0)
		assert_true(UI.f().get_string_size(long, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= 480.0 or size <= 12, "fits at %.2f" % sc)
	UI.scale = 1.3
	assert_eq(UI.scaled(30), 39)
	UI.scale = 1.0

func test_reserved_firebase_event_names_unused() -> void:
	var src := FileAccess.get_file_as_string("res://src/services/analytics.gd") + FileAccess.get_file_as_string("res://src/game/game_screen.gd") + FileAccess.get_file_as_string("res://src/app/home_screen.gd") + FileAccess.get_file_as_string("res://src/services/platform.gd")
	for reserved in ["\"session_start\"", "\"first_open\"", "\"screen_view\"", "\"app_update\"", "\"user_engagement\"", "\"error\""]:
		assert_true(not src.contains("log_event(" + reserved), "reserved Firebase event " + reserved)

func test_missions_deterministic_and_claim_flow() -> void:
	var p := _profile()
	var a: Array = p.missions_today().duplicate(true)
	assert_eq(a.size(), 3)
	var types := {}
	for mi in a:
		types[mi.type] = true
		assert_true(int(mi.reward) >= 40 and int(mi.reward) <= 120, "reward range")
	assert_eq(types.size(), 3, "three different mission types")
	var p2 := _profile()
	assert_eq(JSON.stringify(p2.missions_today()), JSON.stringify(a), "same day → same missions")
	p.data.missions.day = p.today() - 1                       # simulate yesterday's set
	p.data.missions.list = [{"type": "levels", "target": 3, "progress": 3, "claimed": false, "reward": 40}]
	assert_eq(p.missions_today().size(), 3, "new day regenerates")
	var m0: Dictionary = p.missions_today()[0]
	assert_eq(p.claim_mission(0), 0, "cannot claim unfinished")
	p.mission_add(m0.type, 9999)
	assert_eq(int(p.missions_today()[0].progress), int(m0.target), "progress clamps at target")
	var before: int = p.coins()
	var got: int = p.claim_mission(0)
	assert_eq(got, int(m0.reward))
	assert_eq(p.coins(), before + got)
	assert_eq(p.claim_mission(0), 0, "cannot claim twice")
	assert_true(not p.bonus_available(), "bonus needs all three")
	for i in [1, 2]:
		p.mission_add(p.missions_today()[i].type, 9999)
		p.claim_mission(i)
	assert_true(p.bonus_available())
	assert_eq(p.claim_bonus(), p.MISSION_BONUS)
	assert_eq(p.claim_bonus(), 0, "bonus once")
	p.free(); p2.free()

func test_coin_shop() -> void:
	var p := _profile()
	assert_true(not p.buy_skin("disco"), "cannot buy without coins")
	assert_eq(p.coins(), 0, "failed purchase spends nothing")
	p.add_coins(1300, "test")
	assert_true(p.buy_skin("disco"))
	assert_eq(p.coins(), 100)
	assert_eq(String(p.data.skin), "disco", "bought skin equipped")
	assert_true(not p.buy_skin("disco"), "cannot buy twice")
	assert_true(not p.buy_skin("ghost"), "ad-only skin not for coins")
	p.add_coins(2000, "test")
	assert_true(p.buy_style("gece"))
	assert_true(p.data.owned_styles.has("gece"))
	assert_eq(p.level_coins(3), 20)
	assert_eq(p.level_coins(0), 5)
	for s in Skins.SHOP:
		assert_true(Skins.ALL.has(s), "shop skin listed: " + s)
	p.free()
