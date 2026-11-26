extends SceneTree
## godot --headless --path game -s res://tools/dal_botsim.gd -- <first_level> <last_level> <runs>
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var l0 := int(a[0]); var l1 := int(a[1]); var runs := int(a[2])
	for li in range(l0, l1 + 1):
		var won := 0; var caps := 0; var used := 0
		var t0 := Time.get_ticks_msec()
		for r in runs:
			var skill := float(r) / float(max(runs - 1, 1))
			var sim := DalSim.new(DalLevels.make(li))
			var bot := DalBot.new(skill, 31 * li + r, sim)
			while sim.state == "play":
				var p = bot.decide(sim)
				if p != null: sim.drop(p)
				sim.step()
			if sim.state == "won":
				won += 1; used += sim.stones_used
			elif sim.reason == "capsized":
				caps += 1
		print(JSON.stringify({"level": li + 1, "runs": runs, "win_rate": float(won) / runs,
			"capsize_rate": float(caps) / runs, "avg_stones_on_win": float(used) / max(won, 1),
			"budget": DalLevels.make(li).stones, "ms": Time.get_ticks_msec() - t0}))
	quit()
