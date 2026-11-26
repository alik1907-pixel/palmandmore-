extends SceneTree
## Finds a bot seed that wins a given level (for video capture). args: proto level skill
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var li := int(a[0])
	for seed_v in range(1, 60):
		var sim := SisSim.new(SisLevels.make(li))
		var bot := SisBot.new(float(a[1]), seed_v)
		while sim.state == "play" and sim.frame < 3600:
			sim.step(bot.decide(sim))
		if sim.state == "won":
			print("WIN seed=%d frames=%d" % [seed_v, sim.frame])
			break
	quit()
