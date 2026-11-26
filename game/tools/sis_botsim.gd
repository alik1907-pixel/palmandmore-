extends SceneTree
## Headless difficulty measurement: godot --headless --path game -s res://tools/sis_botsim.gd -- <levels> <runs>
func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var levels := int(args[0]) if args.size() > 0 else 6
	var runs := int(args[1]) if args.size() > 1 else 200
	var out := []
	for li in levels:
		var lvl := SisLevels.make(li)
		var won := 0
		var popped := 0
		var frames_sum := 0
		var t0 := Time.get_ticks_msec()
		for r in runs:
			var skill := float(r) / float(max(runs - 1, 1))
			var sim := SisSim.new(lvl)
			var bot := SisBot.new(skill, 1000 * li + r)
			while sim.state == "play" and sim.frame < 60 * 60:
				sim.step(bot.decide(sim))
			if sim.state == "won":
				won += 1
				frames_sum += sim.frame
			elif sim.state == "popped":
				popped += 1
		var row := {"level": li + 1, "runs": runs, "win_rate": float(won) / runs,
			"pop_rate": float(popped) / runs, "avg_win_sec": (frames_sum / 60.0 / won) if won > 0 else 0.0,
			"ms": Time.get_ticks_msec() - t0}
		print(JSON.stringify(row))
		out.append(row)
	quit()
