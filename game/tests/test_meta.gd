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
	for key in I18n.S:
		for lang in I18n.LANGS:
			assert_true((I18n.S[key] as Dictionary).has(lang), "%s missing %s" % [key, lang])

func test_skins_and_styles_have_rules() -> void:
	for s in Skins.ALL:
		assert_true(not Skins.unlock_rule(s).is_empty(), "rule for " + s)
	for st in ArtStyle.IDS:
		assert_eq(ArtStyle.make(st).id, st)

func test_platform_config() -> void:
	var c := PlatformConfig.load_config()
	assert_true(c.admob_app_id.begins_with("ca-app-pub-"))
	assert_true(c.products.has("remove_ads"))
