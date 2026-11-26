extends SceneTree
## Debug trace of one bot run. args: level skill seed every
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var lvl := LevelBuilder.load_level(int(a[0]))
	var sim := BalloonSim.new(lvl)
	seed(int(a[2]))
	var bot = BalloonPlanner.new(float(a[1]), int(a[2])) if (a.size() < 5 or a[4] != "heuristic") else BalloonBot.new(float(a[1]), int(a[2]))
	var every := int(a[3]) if a.size() > 3 else 30
	for g in lvl.gates: print("gate ", g)
	print("finish ", lvl.finish_y)
	while sim.state == "play" and sim.frame < 5400:
		var h := bot.decide(sim)
		sim.step(h)
		if sim.frame % every == 0:
			print("f=%d c=(%.0f,%.0f) r=%.1f tr=%.1f vy=%.0f hold=%s over=%d" % [sim.frame, sim.center().x, sim.center().y, sim.radius(), sim.target_r, sim.velocity().y, h, sim.over_frames])
	print("END ", sim.state, " frame ", sim.frame)
	quit()
