class_name LevelGen
extends RefCounted
## Campaign level generator for levels 16+. Builds a level spec (LevelBuilder
## format) from the same modules the hand-made levels teach, scaled by difficulty
## d (0..1). Offline only: tools/gen_levels.gd validates every candidate with the
## expert planner and a mixed-skill bot population before it is shipped.

static func generate(seed_v: int, d: float) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var rows: Array = [{"type": "gate", "x": 360, "gap": int(lerpf(160.0, 130.0, d)), "space": 250}]
	var x := 360.0
	var modules := 3 + int(round(d * 2.0)) + rng.randi_range(0, 1)
	for i in modules:
		var w := {
			"shift": 1.0,
			"rhythm": lerpf(1.0, 0.4, d),
			"throat": lerpf(0.5, 0.8, d),
			"spiked_throat": lerpf(0.0, 0.8, d),
			"bar": lerpf(0.0, 0.7, d),
			"crosswind": lerpf(0.0, 0.6, d),
		}
		var kind := _pick(rng, w)
		match kind:
			"shift":
				var nx := _shift_target(rng, x)
				rows.append({"type": "wind", "dir": signf(nx - x), "space": rng.randi_range(270, 320),
					"strength": int(lerpf(240.0, 310.0, d))})
				rows.append({"type": "gate", "x": int(nx), "gap": int(lerpf(150.0, 112.0, d) + rng.randi_range(-6, 6)),
					"space": 150, "spiked": rng.randf() < lerpf(0.2, 0.8, d)})
				x = nx
			"rhythm":
				for k in rng.randi_range(2, 3):
					var nx2 := clampf(x + rng.randf_range(-40.0, 40.0), 300.0, 420.0)
					rows.append({"type": "gate", "x": int(nx2), "gap": int(lerpf(125.0, 98.0, d)), "space": rng.randi_range(340, 380)})
					x = nx2
			"throat":
				rows.append({"type": "gate", "x": int(x), "gap": int(lerpf(130.0, 108.0, d)), "space": 400,
					"throat": int(lerpf(110.0, 190.0, d))})
			"spiked_throat":
				rows.append({"type": "gate", "x": int(x), "gap": 150, "space": 400,
					"throat": int(lerpf(80.0, 110.0, d)), "throat_spiked": true})
			"bar":
				# Tavan pattern: drift sideways under a spike ceiling, exit on the open side
				var right := rng.randf() < 0.5
				rows.append({"type": "gate", "x": 360, "gap": 160, "space": 400})
				rows.append({"type": "wind", "dir": 1 if right else -1, "space": 320, "strength": int(lerpf(300.0, 260.0, d))})
				if right:
					rows.append({"type": "bar", "x0": 40, "x1": int(lerpf(400.0, 450.0, d)), "space": 0})
					rows.append({"type": "gate", "x": 590, "gap": int(lerpf(160.0, 140.0, d)), "space": 170, "spiked": d > 0.5})
					x = 590.0
				else:
					rows.append({"type": "bar", "x0": int(lerpf(320.0, 270.0, d)), "x1": 680, "space": 0})
					rows.append({"type": "gate", "x": 130, "gap": int(lerpf(160.0, 140.0, d)), "space": 170, "spiked": d > 0.5})
					x = 130.0
			"crosswind":
				# Ters Rüzgâr pattern: two opposing winds before an offset gate
				var nx3 := _shift_target(rng, x)
				var dir := signf(nx3 - x)
				rows.append({"type": "wind", "dir": -dir, "space": 260, "strength": 300})
				rows.append({"type": "wind", "dir": dir, "space": 260, "strength": 300})
				rows.append({"type": "gate", "x": int(nx3), "gap": int(lerpf(140.0, 118.0, d)), "space": 150, "spiked": true})
				x = nx3
		if kind == "bar":      # bring the shaft back toward the centre after an edge exit
			var back := 360.0
			rows.append({"type": "wind", "dir": signf(back - x), "space": 300, "strength": 280})
			rows.append({"type": "gate", "x": int(back), "gap": int(lerpf(150.0, 125.0, d)), "space": 150})
			x = back
	return {"name": "", "rows": rows, "seed": seed_v, "difficulty": snappedf(d, 0.01)}

static func _shift_target(rng: RandomNumberGenerator, x: float) -> float:
	var nx := x
	while absf(nx - x) < 110.0:
		nx = rng.randf_range(200.0, 520.0)
	return nx

static func _pick(rng: RandomNumberGenerator, weights: Dictionary) -> String:
	var total := 0.0
	for k in weights:
		total += float(weights[k])
	var r := rng.randf() * total
	for k in weights:
		r -= float(weights[k])
		if r <= 0.0:
			return k
	return weights.keys()[0]
