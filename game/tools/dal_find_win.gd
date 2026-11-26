extends SceneTree
func _init() -> void:
	var li := int(OS.get_cmdline_user_args()[0])
	for seed_v in range(1, 40):
		var sim := DalSim.new(DalLevels.make(li))
		var bot := DalBot.new(1.0, seed_v, sim)
		while sim.state == "play":
			var p = bot.decide(sim)
			if p != null: sim.drop(p)
			sim.step()
		if sim.state == "won":
			print("WIN seed=%d frames=%d stones=%d" % [seed_v, sim.frame, sim.stones_used])
	quit()
