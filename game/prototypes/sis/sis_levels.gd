class_name SisLevels
extends RefCounted
## Seeded level generator for the ŞİŞ greybox. Difficulty knobs scale with index.

const W := 720.0
const SIDE_L := 40.0
const SIDE_R := 680.0

static func make(index: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7919 * (index + 1)
	var gates := 3 + index
	var gap: float = max(150.0 - index * 11.0, 66.0)       # neutral diameter is 84
	var spacing: float = max(460.0 - index * 18.0, 330.0)
	var spiky: bool = index >= 2
	var walls: Array = []
	var spikes: Array = []
	var winds: Array = []
	var gate_list: Array = []
	var start := Vector2(360, 1100)
	var y := start.y - 320.0
	var prev_x := 360.0
	for k in gates:
		var gx := rng.randf_range(230.0, 490.0) if (index >= 1 and k > 0) else 360.0
		var dx := gx - prev_x
		var has_wind: bool = abs(dx) > 70.0 and k > 0
		var half := gap * 0.5
		var funnel := half + 110.0
		# full funnel from both side walls up to the gap; outer part spiked later
		var drop := 150.0
		for side in [-1.0, 1.0]:
			var outer := Vector2(SIDE_L if side < 0.0 else SIDE_R, y + drop)
			var inner := Vector2(gx + side * half, y)
			var split_t: float = clamp(1.0 - (funnel - half) / absf(outer.x - inner.x), 0.0, 1.0)
			var mid := outer.lerp(inner, split_t)
			if spiky and has_wind and split_t > 0.02:
				spikes.append([outer, mid])
				walls.append([mid, inner])
			else:
				walls.append([outer, inner])
		# wind zone between previous gate and this one, pushing toward this gap
		if has_wind:
			var zone := Rect2(SIDE_L, y + 190.0, SIDE_R - SIDE_L, spacing - 230.0)
			winds.append([zone, sign(dx) * 260.0])
		gate_list.append({"x": gx, "y": y, "gap": gap})
		prev_x = gx
		y -= spacing
	# side walls
	walls.append([Vector2(SIDE_L, start.y + 200.0), Vector2(SIDE_L, y - 200.0)])
	walls.append([Vector2(SIDE_R, start.y + 200.0), Vector2(SIDE_R, y - 200.0)])
	walls.append([Vector2(SIDE_L, start.y + 120.0), Vector2(SIDE_R, start.y + 120.0)])
	# spike ceiling strip on alternating sides of the shaft from level 4
	if index >= 4:
		for g in gate_list:
			var sx: float = SIDE_L if g.x > 360.0 else SIDE_R
			var dir: float = 1.0 if sx == SIDE_L else -1.0
			spikes.append([Vector2(sx + dir * 2.0, g.y - 80.0), Vector2(sx + dir * 2.0, g.y - 260.0)])
	return {
		"index": index, "start": start, "finish_y": y + spacing * 0.5,
		"walls": walls, "spikes": spikes, "winds": winds, "gates": gate_list,
	}
