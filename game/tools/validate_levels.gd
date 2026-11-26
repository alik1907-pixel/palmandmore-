extends SceneTree
## Bot-population validation of hand-authored levels.
## godot --headless --path game -s res://tools/validate_levels.gd -- <first> <last> <runs>
## Prints one JSON line per level: win/pop/stuck rates, mean win time, solvable flag.
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var l0 := int(a[0]) if a.size() > 0 else 1
	var l1 := int(a[1]) if a.size() > 1 else LevelBuilder.level_count()
	var runs := int(a[2]) if a.size() > 2 else 60
	var mode := a[3] if a.size() > 3 else "planner"
	var use_planner := mode != "heuristic"
	var tuning := Tuning.load_default()
	for n in range(l0, l1 + 1):
		var lvl := LevelBuilder.load_level(n)
		var won := 0; var popped := 0; var stuck := 0; var frames := 0; var over := 0
		var t0 := Time.get_ticks_msec()
		var pop_at := {}
		for r in runs:
			var skill := 1.0 if mode == "expert" else float(r) / float(maxi(runs - 1, 1))
			var sim := BalloonSim.new(lvl, tuning)
			seed(1000 * n + r)
			var bot = BalloonPlanner.new(skill, 1000 * n + r) if use_planner else BalloonBot.new(skill, 1000 * n + r)
			sim.stall_limit_frames = 60 * 15
			while sim.state == "play" and sim.frame < 60 * 90:
				sim.step(bot.decide(sim))
			match sim.state:
				"won": won += 1; frames += sim.frame
				"popped":
					popped += 1
					if sim.over_frames > tuning.pop_frames: over += 1
					var gi := 0
					for g in lvl.gates:
						if sim.pop_point.y < g.y + 200.0: gi += 1
					var key := "g%d" % gi
					pop_at[key] = int(pop_at.get(key, 0)) + 1
				_: stuck += 1
		print(JSON.stringify({"level": n, "name": lvl.name, "win": snappedf(float(won) / runs, 0.001),
			"pop": snappedf(float(popped) / runs, 0.001), "overpop": snappedf(float(over) / runs, 0.001), "stuck": snappedf(float(stuck) / runs, 0.001),
			"win_sec": snappedf(frames / 60.0 / maxf(won, 1), 0.1), "solvable": won > 0, "pop_at": pop_at,
			"ms": Time.get_ticks_msec() - t0}))
	quit()
