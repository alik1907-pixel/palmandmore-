extends TestCase
## Level data integrity + every level beaten by the expert planner.

func test_all_levels_load() -> void:
	assert_eq(LevelBuilder.campaign_file_count(), 50)
	assert_true(LevelBuilder.level_count() >= 50 + 2 * 900, "endless bank present (%d levels)" % LevelBuilder.level_count())
	var sample: Array = range(1, 51)
	for k in [51, 52, 300, 700, LevelBuilder.level_count() / 2 + 40, LevelBuilder.level_count()]:
		sample.append(k)
	for n in sample:
		var l := LevelBuilder.load_level(n)
		assert_true(not l.is_empty(), "level %d loads" % n)
		assert_true(l.gates.size() >= 3, "level %d has gates" % n)
		assert_lt(l.finish_y, l.start.y, "level %d finish above start" % n)
		I18n.set_lang("en")
		assert_true(I18n.level_name(n) != "", "level %d named" % n)
		assert_true(float(l.get("par", 0.0)) > 0.0, "level %d has par" % n)

func test_every_level_solvable_by_expert() -> void:
	## All 50 campaign levels + a spread of bank levels and their mirrored copies.
	var bank := LevelBuilder.level_count() / 2 - LevelBuilder.campaign_file_count() / 2
	var ids: Array = range(1, LevelBuilder.campaign_file_count() + 1)
	for k in [51, 137, 402, 777, 951]:
		ids.append(k)
		ids.append(k + bank)            # same level, mirrored
	for n in ids:
		seed(n)
		var sim := BalloonSim.new(LevelBuilder.load_level(n))
		var bot := BalloonPlanner.new(1.0, n)
		while sim.state == "play" and sim.frame < 60 * 90:
			sim.step(bot.decide(sim))
		assert_eq(sim.state, "won", "level %d" % n)

func test_mirror_is_exact_reflection() -> void:
	## Every wall/spike of the original has a mirrored twin (x → 720 − x) in the copy.
	for n in [51, 400, 900]:
		var spec := LevelBuilder.spec_for(n)
		var a := LevelBuilder.build(spec)
		var b := LevelBuilder.build(LevelBuilder.mirror(spec))
		assert_eq(a.walls.size(), b.walls.size(), "wall count %d" % n)
		assert_eq(a.spikes.size(), b.spikes.size(), "spike count %d" % n)
		assert_eq(a.finish_y, b.finish_y)
		for kind in ["walls", "spikes"]:
			var missing := 0
			for seg in a[kind]:
				var m0 := Vector2(720.0 - (seg[0] as Vector2).x, (seg[0] as Vector2).y)
				var m1 := Vector2(720.0 - (seg[1] as Vector2).x, (seg[1] as Vector2).y)
				var found := false
				for other in b[kind]:
					var o0: Vector2 = other[0]
					var o1: Vector2 = other[1]
					if (o0.distance_to(m0) < 0.01 and o1.distance_to(m1) < 0.01) or (o0.distance_to(m1) < 0.01 and o1.distance_to(m0) < 0.01):
						found = true
						break
				if not found:
					missing += 1
			assert_eq(missing, 0, "%s mirrored in level %d" % [kind, n])
