extends SceneTree
## Builds part of the endless campaign bank (levels 51+). Every level is solved by
## the expert planner before it is kept (par = expert seconds).
## Difficulty for bank index k: a slowly rising average with a 10-level wave, so
## hard stretches are followed by breathers.
## args: <first_index> <count> <seed_base> <out.json>
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var k0 := int(a[0]); var count := int(a[1]); var sbase := int(a[2]); var out := String(a[3])
	var res: Array = []
	var k := k0
	var attempt := 0
	while res.size() < count and attempt < count * 4:
		attempt += 1
		var d := difficulty(k)
		var sd := sbase + attempt
		var spec := LevelGen.generate(sd, d)
		seed(sd)
		var sim := BalloonSim.new(LevelBuilder.build(spec))
		var bot := BalloonPlanner.new(1.0, sd)
		while sim.state == "play" and sim.frame < 60 * 60:
			sim.step(bot.decide(sim))
		if sim.state != "won" or sim.frame > 60 * 40:
			continue                     # unsolved or too long for a mobile session
		spec["par"] = snappedf(sim.frame / 60.0, 0.1)
		spec["bank_index"] = k
		res.append(spec)
		if res.size() % 10 == 0:
			print("ok %d/%d (k=%d d=%.2f)" % [res.size(), count, k, d])
		k += 1
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(res))
	print("DONE ", res.size())
	quit()

static func difficulty(k: int) -> float:
	var base := 0.45 + 0.35 * minf(k / 400.0, 1.0)
	var wave := 0.22 * sin(TAU * k / 10.0)
	return clampf(base + wave, 0.12, 1.0)
