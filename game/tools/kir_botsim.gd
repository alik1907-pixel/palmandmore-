extends SceneTree
## godot --headless --path game -s res://tools/kir_botsim.gd -- <levels> <runs>
func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var levels := int(args[0]) if args.size() > 0 else 6
	var runs := int(args[1]) if args.size() > 1 else 200
	for li in levels:
		var lvl := KirLevels.make(li)
		var base := KirSim.new(lvl, false)
		var won := 0
		var taps_sum := 0
		var loss_sum := 0.0
		var t0 := Time.get_ticks_msec()
		for r in runs:
			var skill := float(r) / float(max(runs - 1, 1))
			var sim := base.clone()
			var bot := KirBot.new(skill, 77 * li + r)
			while sim.state == "play":
				sim.tap(bot.choose(sim))
			if sim.state == "won":
				won += 1
				taps_sum += sim.taps_used
			loss_sum += sim.counts().loss
		print(JSON.stringify({"level": li + 1, "runs": runs, "win_rate": float(won) / runs,
			"avg_taps_on_win": float(taps_sum) / max(won, 1), "budget": lvl.taps,
			"avg_target_loss": loss_sum / runs, "shards": base.sites.size(), "ms": Time.get_ticks_msec() - t0}))
	quit()
