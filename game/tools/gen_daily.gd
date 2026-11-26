extends SceneTree
## Builds data/daily/pool.json: procedural specs that the expert solves and a
## mixed bot population clears 35–85% of the time. args: <count> <first_seed> <out>
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var want := int(a[0]); var s := int(a[1]); var out := String(a[2])
	var pool: Array = []
	var tried := 0
	while pool.size() < want and tried < want * 8:
		tried += 1
		var spec := Daily.generate(s + tried)
		var lvl := LevelBuilder.build(spec)
		seed(tried)
		var sim := BalloonSim.new(lvl)
		var bot := BalloonPlanner.new(1.0, tried)
		while sim.state == "play" and sim.frame < 60 * 60:
			sim.step(bot.decide(sim))
		if sim.state != "won":
			continue
		var par := sim.frame / 60.0
		var wins := 0
		for r in 6:
			seed(tried * 10 + r)
			var s2 := BalloonSim.new(lvl)
			var b2 := BalloonPlanner.new(0.15 + 0.17 * r, tried * 10 + r)
			while s2.state == "play" and s2.frame < 60 * 60:
				s2.step(b2.decide(s2))
			if s2.state == "won": wins += 1
		var rate := wins / 6.0
		if rate < 0.3 or rate > 0.86:
			continue
		spec["par"] = snappedf(par, 0.1)
		spec["bot_clear"] = snappedf(rate, 0.01)
		pool.append(spec)
		print("ok seed=%d par=%.1f clear=%.2f (%d/%d)" % [spec.seed, par, rate, pool.size(), want])
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(pool, " "))
	print("DONE ", pool.size())
	quit()
