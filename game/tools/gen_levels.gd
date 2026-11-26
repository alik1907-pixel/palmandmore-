extends SceneTree
## Generates campaign candidates and measures them.
## args: <count> <first_seed> <d_min> <d_max> <out.json>
## Each accepted candidate: expert planner wins, then 10 bots (skill 0.1..1.0)
## give a clear rate; stored with par (expert seconds) for selection by
## tools/select_levels.py.
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var want := int(a[0]); var s0 := int(a[1])
	var dmin := float(a[2]); var dmax := float(a[3]); var out := String(a[4])
	var res: Array = []
	var tried := 0
	while res.size() < want and tried < want * 6:
		tried += 1
		var d := lerpf(dmin, dmax, float(res.size()) / maxf(want - 1, 1))
		var spec := LevelGen.generate(s0 + tried, d)
		var lvl := LevelBuilder.build(spec)
		seed(s0 + tried)
		var sim := BalloonSim.new(lvl)
		var bot := BalloonPlanner.new(1.0, s0 + tried)
		while sim.state == "play" and sim.frame < 60 * 75:
			sim.step(bot.decide(sim))
		if sim.state != "won":
			continue
		var par := sim.frame / 60.0
		var wins := 0
		for r in 10:
			seed((s0 + tried) * 10 + r)
			var s2 := BalloonSim.new(lvl)
			s2.stall_limit_frames = 60 * 15
			var b2 := BalloonPlanner.new(0.1 + 0.1 * r, (s0 + tried) * 10 + r)
			while s2.state == "play" and s2.frame < 60 * 75:
				s2.step(b2.decide(s2))
			if s2.state == "won":
				wins += 1
		spec["par"] = snappedf(par, 0.1)
		spec["bot_clear"] = wins / 10.0
		res.append(spec)
		print("ok d=%.2f par=%.1f clear=%.1f (%d/%d)" % [d, par, spec.bot_clear, res.size(), want])
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(res, " "))
	print("DONE ", res.size())
	quit()
