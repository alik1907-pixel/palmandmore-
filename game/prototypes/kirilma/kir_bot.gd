class_name KirBot
extends RefCounted
## Look-ahead player: samples candidate taps on non-target shards, simulates each
## and picks the best (skill = chance to pick the best instead of a random candidate).

var skill := 0.5
var rng := RandomNumberGenerator.new()
var samples := 10

func _init(p_skill: float, seed_v: int) -> void:
	skill = p_skill
	rng.seed = seed_v
	samples = int(lerp(4.0, 24.0, skill))

func choose(sim: KirSim) -> Vector2:
	var live: Array = []
	for i in sim.sites.size():
		if sim.alive[i] and not sim.is_target[i]:
			live.append(i)
	if live.is_empty():
		return Vector2.ZERO
	var best_p: Vector2 = sim.sites[live[0]]
	var best_s := -INF
	var cands: Array = []
	# prefer shards on the ornament outline (what a human carving would do)
	var rim: Array = []
	for i in live:
		for j in sim.adj[i]:
			if sim.is_target[j] and sim.alive[j]:
				rim.append(i)
				break
	for _k in samples:
		var pool: Array = rim if (rim.size() > 0 and rng.randf() < 0.6) else live
		cands.append(sim.sites[pool[rng.randi() % pool.size()]])
	if rng.randf() > skill:
		return cands[rng.randi() % cands.size()]
	var before: Dictionary = sim.counts()
	for p in cands:
		var c := sim.clone()
		c.tap(p)
		var after := c.counts()
		var gain: float = before.other_alive - after.other_alive
		var loss: float = before.target_alive - after.target_alive
		var rim_left := 0
		for i in rim:
			if c.alive[i]:
				rim_left += 1
		var score: float = gain - 8.0 * loss - 0.5 * rim_left
		if score > best_s:
			best_s = score
			best_p = p
	return best_p
