extends SceneTree
## Finds planner seeds with a given outcome (for autoplay videos).
## args: level skill outcome(won|popped) max_frames
## NOTE: game_screen reseeds the planner with seed+1 at level start.
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var lvl := LevelBuilder.load_level(int(a[0]))
	var found := 0
	for s in range(1, 200):
		seed(s + 1)
		var sim := BalloonSim.new(lvl)
		var bot := BalloonPlanner.new(float(a[1]), s + 1)
		while sim.state == "play" and sim.frame < int(a[3]):
			sim.step(bot.decide(sim))
		if sim.state == a[2]:
			print("seed=%d frames=%d at=%s" % [s, sim.frame, sim.pop_point])
			found += 1
			if found >= 5: break
	quit()
