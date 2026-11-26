class_name Daily
extends RefCounted
## Daily shaft: everyone gets the same level on the same local date.
## Levels come from a pre-validated pool (tools/gen_daily.gd), so every daily is
## guaranteed solvable by the expert planner and sits in a medium difficulty band.

const LAUNCH_DAY := 20800      # day index used as "Daily #1" (2026-12-14 local)
const POOL := "res://data/daily/pool.json"

static func pool_size() -> int:
	return _pool().size()

static func _pool() -> Array:
	var f := FileAccess.open(POOL, FileAccess.READ)
	if f == null:
		return []
	var d = JSON.parse_string(f.get_as_text())
	return d if d is Array else []

static func number_for(day: int) -> int:
	return maxi(day - LAUNCH_DAY + 1, 1)

static func level_for(day: int) -> Dictionary:
	var pool := _pool()
	if pool.is_empty():
		return {}
	var spec: Dictionary = pool[posmod(day, pool.size())]
	var lvl := LevelBuilder.build(spec)
	lvl["number"] = -number_for(day)
	lvl["par"] = float(spec.get("par", 20.0))
	return lvl

## Procedural spec from a seed (used offline by the generator).
static func generate(seed_v: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var rows: Array = [{"type": "gate", "x": 360, "gap": rng.randi_range(120, 150), "space": 250}]
	var x := 360.0
	var n := rng.randi_range(4, 6)
	for i in n:
		var roll := rng.randf()
		var nx := clampf(x + rng.randf_range(-170.0, 170.0), 200.0, 520.0)
		var gap := rng.randi_range(110, 140)
		if absf(nx - x) > 90.0:
			rows.append({"type": "wind", "dir": signf(nx - x), "space": rng.randi_range(260, 320), "strength": rng.randi_range(240, 300)})
			var g := {"type": "gate", "x": int(nx), "gap": gap, "space": 150, "spiked": rng.randf() < 0.5}
			rows.append(g)
		elif roll < 0.35:
			var spiked := rng.randf() < 0.4
			rows.append({"type": "gate", "x": int(x), "gap": 150 if spiked else gap, "space": 400,
				"throat": rng.randi_range(90, 120) if spiked else rng.randi_range(110, 170), "throat_spiked": spiked})
			nx = x
		else:
			rows.append({"type": "gate", "x": int(nx), "gap": gap, "space": rng.randi_range(360, 420)})
		x = nx
	return {"name": "Daily", "rows": rows, "seed": seed_v}
