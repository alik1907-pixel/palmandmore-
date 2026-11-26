class_name DalBot
extends RefCounted
## Navigates with a BFS distance field from the goal; drops a stone behind the
## lantern along the descent direction. Skill = aim noise, distance judgement, patience.

var skill := 0.5
var rng := RandomNumberGenerator.new()
var dist := PackedInt32Array()
var cooldown := 0

func _init(p_skill: float, seed_v: int, sim: DalSim) -> void:
	skill = p_skill
	rng.seed = seed_v
	_build_field(sim)

func _build_field(sim: DalSim) -> void:
	var n := DalSim.GW * DalSim.GH
	dist.resize(n)
	dist.fill(1 << 30)
	var gi := int(sim.goal.y / DalSim.CELL) * DalSim.GW + int(sim.goal.x / DalSim.CELL)
	dist[gi] = 0
	var q := [gi]
	var head := 0
	while head < q.size():
		var i: int = q[head]
		head += 1
		for o in [-1, 1, -DalSim.GW, DalSim.GW]:
			var j: int = i + o
			if j >= 0 and j < n and sim.wall[j] == 0 and dist[j] > dist[i] + 1:
				dist[j] = dist[i] + 1
				q.append(j)

func _descent(sim: DalSim, p: Vector2) -> Vector2:
	var x := int(p.x / DalSim.CELL)
	var y := int(p.y / DalSim.CELL)
	var best := Vector2.ZERO
	var bd: int = dist[y * DalSim.GW + x]
	# look a few cells ahead for a smoother direction
	for dy in range(-3, 4):
		for dx in range(-3, 4):
			var xx := x + dx
			var yy := y + dy
			if xx < 0 or yy < 0 or xx >= DalSim.GW or yy >= DalSim.GH:
				continue
			var d: int = dist[yy * DalSim.GW + xx]
			if d < bd:
				bd = d
				best = Vector2(dx, dy)
	return best.normalized()

## Returns a drop position, or null when waiting.
func decide(sim: DalSim):
	if cooldown > 0:
		cooldown -= 1
		return null
	if sim.vel.length() > lerp(10.0, 30.0, skill):
		return null
	var dir := _descent(sim, sim.lantern)
	if dir == Vector2.ZERO:
		return null
	var ang := rng.randfn(0.0, lerp(0.6, 0.12, skill))
	var back := rng.randf_range(lerp(42.0, 56.0, skill), lerp(170.0, 85.0, skill))
	var p := sim.lantern - dir.rotated(ang) * back
	cooldown = int(lerp(50.0, 80.0, skill))
	if sim.is_wall_at(p):
		p = sim.lantern - dir.rotated(ang) * 60.0
	return p
