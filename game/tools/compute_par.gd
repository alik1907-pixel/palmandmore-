extends SceneTree
## Writes "par" (expert planner seconds) into every data/levels/NN.json.
func _init() -> void:
	for n in range(1, LevelBuilder.level_count() + 1):
		var path := "res://data/levels/%02d.json" % n
		var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		seed(n)
		var sim := BalloonSim.new(LevelBuilder.build(spec))
		var bot := BalloonPlanner.new(1.0, n)
		while sim.state == "play" and sim.frame < 60 * 90:
			sim.step(bot.decide(sim))
		spec["par"] = snappedf(sim.frame / 60.0, 0.1)
		var f := FileAccess.open(path, FileAccess.WRITE)
		f.store_string(JSON.stringify(spec, " ", false))
		print("%d %s par=%.1f %s" % [n, spec.name, spec.par, sim.state])
	quit()
