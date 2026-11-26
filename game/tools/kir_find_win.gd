extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var li := int(a[0])
	for seed_v in range(1, 80):
		var sim := KirSim.new(KirLevels.make(li), false)
		var bot := KirBot.new(1.0, seed_v)
		while sim.state == "play":
			sim.tap(bot.choose(sim))
		if sim.state == "won":
			print("WIN seed=%d taps=%d loss=%.2f" % [seed_v, sim.taps_used, sim.counts().loss])
			break
	quit()
