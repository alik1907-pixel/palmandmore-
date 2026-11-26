extends SceneTree
func _init() -> void:
	for d in [40.0, 60.0, 80.0, 110.0, 150.0, 200.0]:
		var sim := DalSim.new(DalLevels.make(0))
		sim.drop(sim.lantern + Vector2(0, d))
		var mx := 0.0
		var start := sim.lantern
		for f in 240:
			var e := 8.0
			var gx := (sim.sample(sim.lantern + Vector2(e, 0)) - sim.sample(sim.lantern - Vector2(e, 0))) / (2.0 * e) * 16.0
			var gy := (sim.sample(sim.lantern + Vector2(0, e)) - sim.sample(sim.lantern - Vector2(0, e))) / (2.0 * e) * 16.0
			mx = max(mx, Vector2(gx, gy).length())
			sim.state = "play"
			sim.step()
		print("d=%d max_slope=%.2f moved=%.1f state=%s" % [d, mx, sim.lantern.distance_to(start), sim.state])
	quit()
