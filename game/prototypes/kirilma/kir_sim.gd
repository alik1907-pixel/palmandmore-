class_name KirSim
extends RefCounted
## KIRILMA greybox: sculpt by shattering. A hanging ice sheet is a Voronoi mosaic.
## Tap a shard -> it cracks along its visible grain line; everything that loses
## its connection to the top anchor falls. Goal: reveal the hidden ornament
## (target silhouette) while losing as little of it as possible, within a tap budget.

const TOP := 200.0
const BOTTOM := 1040.0
const LEFT := 70.0
const RIGHT := 650.0
const BURST_R := 20.0
const CRACK_LEN := 260.0
const WIN_LEFTOVER := 0.12   # max share of non-target ice allowed to remain
const LOSS_LIMIT := 0.15     # max share of target shards allowed to break

var sites := PackedVector2Array()
var polys: Array = []          # PackedVector2Array per shard
var grain := PackedFloat32Array()
var is_target: Array = []
var alive: Array = []
var adj: Array = []            # Array[PackedInt32Array]
var spacing := 36.0
var taps_left := 0
var taps_used := 0
var state := "play"            # play | won | lost
var target_total := 0
var other_total := 0
var last_fallen: Array = []    # shard ids removed by the last tap (for the view)
var target_poly := PackedVector2Array()

func _init(lvl: Dictionary, build_geometry := true) -> void:
	if lvl.is_empty():
		return
	taps_left = lvl.taps
	target_poly = lvl.target
	var rng := RandomNumberGenerator.new()
	rng.seed = lvl.seed
	spacing = lvl.spacing
	var y := TOP + spacing * 0.5
	while y < BOTTOM:
		var x := LEFT + spacing * 0.5
		while x < RIGHT:
			sites.append(Vector2(x + rng.randf_range(-0.35, 0.35) * spacing, y + rng.randf_range(-0.35, 0.35) * spacing))
			grain.append(rng.randf_range(0.0, PI))
			x += spacing
		y += spacing
	var n := sites.size()
	for i in n:
		var t := Geometry2D.is_point_in_polygon(sites[i], target_poly)
		is_target.append(t)
		alive.append(true)
		if t: target_total += 1
		else: other_total += 1
		var nb := PackedInt32Array()
		for j in n:
			if j != i and sites[i].distance_to(sites[j]) < spacing * 1.55:
				nb.append(j)
		adj.append(nb)
	if build_geometry:
		_build_cells()

func _build_cells() -> void:
	var rect := PackedVector2Array([Vector2(LEFT, TOP), Vector2(RIGHT, TOP), Vector2(RIGHT, BOTTOM), Vector2(LEFT, BOTTOM)])
	for i in sites.size():
		var cell := rect
		for j in sites.size():
			if j == i or sites[i].distance_to(sites[j]) > spacing * 2.6:
				continue
			var mid := (sites[i] + sites[j]) * 0.5
			var d := (sites[j] - sites[i]).normalized()
			var t := Vector2(-d.y, d.x) * 2000.0
			# half-plane on site i's side of the bisector
			var hp := PackedVector2Array([mid + t, mid + t - d * 2000.0, mid - t - d * 2000.0, mid - t])
			var res := Geometry2D.intersect_polygons(cell, hp)
			if res.size() > 0:
				cell = res[0]
		polys.append(cell)

func nearest(p: Vector2) -> int:
	var best := -1
	var bd := INF
	for i in sites.size():
		if not alive[i]:
			continue
		var d := sites[i].distance_squared_to(p)
		if d < bd:
			bd = d
			best = i
	if best >= 0 and bd > spacing * spacing:
		return -1
	return best

func tap(p: Vector2) -> void:
	last_fallen = []
	if state != "play":
		return
	var s := nearest(p)
	if s < 0:
		return
	taps_left -= 1
	taps_used += 1
	var dir := Vector2(cos(grain[s]), sin(grain[s]))
	var origin := sites[s]
	var fwd: Array = []
	var back: Array = []
	for i in sites.size():
		if not alive[i]:
			continue
		var rel := sites[i] - origin
		var along := rel.dot(dir)
		var across := absf(rel.cross(dir))
		if rel.length() < BURST_R:
			alive[i] = false
			last_fallen.append(i)
		elif absf(along) < CRACK_LEN and across < spacing * 0.45:
			(fwd if along > 0.0 else back).append([absf(along), i])
	# the crack runs outward; ornament material is tougher: the crack breaks
	# the first ornament shard it reaches and stops in that direction.
	for arr in [fwd, back]:
		arr.sort_custom(func(a, b): return a[0] < b[0])
		for e in arr:
			var i: int = e[1]
			alive[i] = false
			last_fallen.append(i)
			if is_target[i]:
				break
	_drop_unanchored()
	_evaluate()

func _drop_unanchored() -> void:
	var seen := {}
	var stack: Array = []
	for i in sites.size():
		if alive[i] and is_target[i] and sites[i].y < TOP + spacing * 0.9:
			stack.append(i)
			seen[i] = true
	while stack.size() > 0:
		var i: int = stack.pop_back()
		for j in adj[i]:
			if alive[j] and not seen.has(j):
				seen[j] = true
				stack.append(j)
	for i in sites.size():
		if alive[i] and not seen.has(i):
			alive[i] = false
			last_fallen.append(i)

func counts() -> Dictionary:
	var t_alive := 0
	var o_alive := 0
	for i in sites.size():
		if alive[i]:
			if is_target[i]: t_alive += 1
			else: o_alive += 1
	return {"target_alive": t_alive, "other_alive": o_alive,
		"loss": 1.0 - float(t_alive) / max(target_total, 1),
		"leftover": float(o_alive) / max(other_total, 1)}

func _evaluate() -> void:
	var c := counts()
	if c.loss > LOSS_LIMIT:
		state = "lost"
	elif c.leftover <= WIN_LEFTOVER:
		state = "won"
	elif taps_left <= 0:
		state = "lost"

func clone() -> KirSim:
	var k := KirSim.new({}, false)
	k.target_poly = target_poly
	k.spacing = spacing
	k.sites = sites
	k.grain = grain
	k.is_target = is_target
	k.adj = adj
	k.alive = alive.duplicate()
	k.target_total = target_total
	k.other_total = other_total
	k.taps_left = taps_left
	k.taps_used = taps_used
	return k
