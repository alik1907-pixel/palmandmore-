class_name LevelBuilder
extends RefCounted
## Turns a hand-authored level spec (data/levels/NN.json) into collision geometry.
## The shaft runs upward (world y decreases). Each row has `space` = vertical
## distance from the cursor; the cursor then moves to the row's top.
##
## Row types:
##   gate  {x, gap, space, spiked?:bool, throat?:px, throat_spiked?:bool}
##   wind  {dir:-1|1, strength?:px/s², space}      zone covers the space it advances
##   bar   {x0, x1, space}                         horizontal spike bar
##   strip {side:"L"|"R", length, space}           spike strip on a side wall, going up

const SIDE_L := 40.0
const SIDE_R := 680.0
const START_Y := 1100.0
const FUNNEL_DROP := 150.0
const FUNNEL_SAFE := 130.0      # unspiked rim beside the gap
const DEFAULT_WIND := 260.0
const THROAT_COLLAR := 40.0     # unspiked mouth of a spiked throat

static func load_level(n: int) -> Dictionary:
	var path := "res://data/levels/%02d.json" % n
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var spec: Dictionary = JSON.parse_string(f.get_as_text())
	var lvl := build(spec)
	lvl["number"] = n
	return lvl

static func level_count() -> int:
	var n := 0
	while FileAccess.file_exists("res://data/levels/%02d.json" % (n + 1)):
		n += 1
	return n

static func build(spec: Dictionary) -> Dictionary:
	var walls: Array = []
	var spikes: Array = []
	var winds: Array = []
	var gates: Array = []
	var bars: Array = []
	var start := Vector2(float(spec.get("start_x", 360.0)), START_Y)
	var y := START_Y - 180.0
	for row in spec.rows:
		var space := float(row.get("space", 400.0))
		match String(row.type):
			"gate":
				y -= space
				var gx := float(row.x)
				var half := float(row.gap) * 0.5
				var spiked := bool(row.get("spiked", false))
				for side in [-1.0, 1.0]:
					var wall_x := SIDE_L if side < 0.0 else SIDE_R
					var inner := Vector2(gx + side * half, y)
					# keep slopes >= ~33° so a rising balloon always slides toward the gap
					var drop := maxf(FUNNEL_DROP, absf(wall_x - inner.x) * 0.65)
					var outer := Vector2(wall_x, y + drop)
					var span := absf(outer.x - inner.x)
					var split_t := clampf(1.0 - FUNNEL_SAFE / maxf(span, 1.0), 0.0, 1.0)
					var mid := outer.lerp(inner, split_t)
					if spiked and split_t > 0.02:
						spikes.append([outer, mid])
						walls.append([mid, inner])
					else:
						walls.append([outer, inner])
				var throat := float(row.get("throat", 0.0))
				if throat > 0.0:
					if bool(row.get("throat_spiked", false)):
						# safe collar at the mouth so entering is fair, spikes above it
						var collar := minf(THROAT_COLLAR, throat)
						for sx in [gx - half, gx + half]:
							walls.append([Vector2(sx, y), Vector2(sx, y - collar)])
							if throat > collar:
								spikes.append([Vector2(sx, y - collar), Vector2(sx, y - throat)])
					else:
						walls.append([Vector2(gx - half, y), Vector2(gx - half, y - throat)])
						walls.append([Vector2(gx + half, y), Vector2(gx + half, y - throat)])
				gates.append({"x": gx, "y": y, "gap": float(row.gap), "throat": throat, "spiked": spiked})
				y -= throat
			"wind":
				var top := y - space
				var strength := float(row.get("strength", DEFAULT_WIND)) * float(row.dir)
				winds.append({"rect": Rect2(SIDE_L, top, SIDE_R - SIDE_L, y - top), "accel": strength})
				y = top
			"bar":
				y -= space
				spikes.append([Vector2(float(row.x0), y), Vector2(float(row.x1), y)])
				bars.append({"x0": float(row.x0), "x1": float(row.x1), "y": y})
			"strip":
				y -= space
				var sx := SIDE_L + 2.0 if String(row.side) == "L" else SIDE_R - 2.0
				spikes.append([Vector2(sx, y), Vector2(sx, y - float(row.length))])
	var finish_y := y - 260.0
	walls.append([Vector2(SIDE_L, START_Y + 200.0), Vector2(SIDE_L, finish_y - 600.0)])
	walls.append([Vector2(SIDE_R, START_Y + 200.0), Vector2(SIDE_R, finish_y - 600.0)])
	walls.append([Vector2(SIDE_L, START_Y + 120.0), Vector2(SIDE_R, START_Y + 120.0)])
	return {
		"name": spec.get("name", ""), "hint": spec.get("hint", ""), "start": start,
		"overpop": bool(spec.get("overpop", true)),
		"finish_y": finish_y, "walls": walls, "spikes": spikes, "winds": winds,
		"gates": gates, "bars": bars,
	}
