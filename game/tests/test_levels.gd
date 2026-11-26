extends TestCase
## Level data integrity + every level beaten by the expert planner.

func test_all_levels_load() -> void:
	assert_eq(LevelBuilder.level_count(), 50)
	for n in range(1, LevelBuilder.level_count() + 1):
		var l := LevelBuilder.load_level(n)
		assert_true(not l.is_empty(), "level %d loads" % n)
		assert_true(l.gates.size() >= 3, "level %d has gates" % n)
		assert_lt(l.finish_y, l.start.y, "level %d finish above start" % n)
		I18n.set_lang("en")
		assert_true(I18n.level_name(n) != "", "level %d named" % n)
		assert_true(float(JSON.parse_string(FileAccess.get_file_as_string("res://data/levels/%02d.json" % n)).get("par", 0.0)) > 0.0, "level %d has par" % n)

func test_every_level_solvable_by_expert() -> void:
	for n in range(1, LevelBuilder.level_count() + 1):
		seed(n)
		var sim := BalloonSim.new(LevelBuilder.load_level(n))
		var bot := BalloonPlanner.new(1.0, n)
		while sim.state == "play" and sim.frame < 60 * 90:
			sim.step(bot.decide(sim))
		assert_eq(sim.state, "won", "level %d" % n)
