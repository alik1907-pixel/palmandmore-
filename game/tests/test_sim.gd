extends TestCase
## Core simulation rules and determinism.

func _run_planner(level: int, frames: int, seed_v: int) -> BalloonSim:
	seed(seed_v)
	var sim := BalloonSim.new(LevelBuilder.load_level(level))
	var bot := BalloonPlanner.new(1.0, seed_v)
	while sim.state == "play" and sim.frame < frames:
		sim.step(bot.decide(sim))
	return sim

func _replay(level: int, inputs: PackedByteArray) -> BalloonSim:
	var sim := BalloonSim.new(LevelBuilder.load_level(level))
	for b in inputs:
		sim.step(b == 1)
	return sim

func test_replay_reproduces_run_exactly() -> void:
	for level in [2, 7, 12]:
		var live := _run_planner(level, 900, 42)
		var rep := _replay(level, live.inputs)
		assert_eq(rep.state_hash(), live.state_hash(), "level %d" % level)
		assert_eq(rep.state, live.state, "level %d" % level)
		assert_eq(rep.frame, live.frame, "level %d" % level)

func test_same_inputs_twice_same_hash() -> void:
	var inputs := PackedByteArray()
	for i in 1200:
		inputs.append(1 if (i / 23) % 3 != 0 else 0)
	assert_eq(_replay(5, inputs).state_hash(), _replay(5, inputs).state_hash())

func test_clone_is_independent() -> void:
	var sim := BalloonSim.new(LevelBuilder.load_level(1))
	for i in 30: sim.step(true)
	var h := sim.state_hash()
	var c := sim.clone()
	for i in 60: c.step(false)
	assert_eq(sim.state_hash(), h)
	assert_true(c.state_hash() != h, "clone diverged")

func test_no_overinflate_pop_in_tutorial_levels() -> void:
	for level in [1, 2]:
		var sim := BalloonSim.new(LevelBuilder.load_level(level))
		for i in 600: sim.step(true)
		assert_true(sim.state != "popped", "level %d state=%s" % [level, sim.state])

func test_overinflate_pops_from_level_3() -> void:
	var sim := BalloonSim.new(LevelBuilder.load_level(3))
	var cause := ""
	for i in 400:
		sim.step(true)
		for e in sim.events:
			if e.type == "pop": cause = e.cause
	assert_eq(sim.state, "popped")
	assert_eq(cause, "overinflate")

func test_spike_contact_pops() -> void:
	var lvl := LevelBuilder.build({"rows": [{"type": "bar", "x0": 200, "x1": 520, "space": 0}]})
	var sim := BalloonSim.new(lvl)
	var cause := ""
	for i in 300:
		sim.step(i < 70)
		for e in sim.events:
			if e.type == "pop": cause = e.cause
	assert_eq(cause, "spike")

func test_deflated_balloon_sinks_inflated_rises() -> void:
	var up := BalloonSim.new(LevelBuilder.load_level(1))
	var down := BalloonSim.new(LevelBuilder.load_level(1))
	for i in 40:
		up.step(true)
		down.step(false)
	assert_lt(up.center().y, LevelBuilder.START_Y - 20.0, "inflated rises")
	assert_lt(LevelBuilder.START_Y - 1.0, down.center().y, "deflated sinks")

func test_step_cost_under_budget() -> void:
	var sim := BalloonSim.new(LevelBuilder.load_level(15))
	var t0 := Time.get_ticks_usec()
	var n := 0
	while sim.state == "play" and n < 1500:
		sim.step((n / 20) % 2 == 0)
		n += 1
	var us := float(Time.get_ticks_usec() - t0) / maxf(n, 1)
	print("    sim step avg: %.1f us over %d frames" % [us, n])
	assert_lt(us, 1000.0, "sim step must stay far below the 16.6 ms frame")
