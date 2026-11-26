class_name KirLevels
extends RefCounted
## Ornament silhouettes hanging from the anchor by a stem. Harder levels: thinner
## features, finer mosaic, fewer taps.

static func make(index: int) -> Dictionary:
	var c := Vector2(360, 690)
	var shape: PackedVector2Array
	match index % 8:
		0: shape = _circle(c, 190.0, 40)
		1: shape = _heart(c, 15.0)
		2: shape = _star(c, 230.0, 105.0, 5)
		3: shape = _arrow(c)
		4: shape = _crescent(c)
		5: shape = _star(c, 250.0, 80.0, 6)
		6: shape = _key(c)
		_: shape = _star(c, 260.0, 70.0, 8)
	var stem_w: float = 2.6 * 40.0
	var top_y := _min_y(shape)
	var stem := PackedVector2Array([Vector2(360 - stem_w * 0.5, KirSim.TOP - 10.0), Vector2(360 + stem_w * 0.5, KirSim.TOP - 10.0),
		Vector2(360 + stem_w * 0.5, top_y + 30.0), Vector2(360 - stem_w * 0.5, top_y + 30.0)])
	var merged := Geometry2D.merge_polygons(shape, stem)
	var target: PackedVector2Array = merged[0]
	for m in merged:
		if (m as PackedVector2Array).size() > target.size():
			target = m
	return {"index": index, "target": target, "seed": 4243 * (index + 3),
		"spacing": 40.0, "taps": 19 - index / 2}

static func _min_y(p: PackedVector2Array) -> float:
	var m := INF
	for v in p: m = min(m, v.y)
	return m

static func _circle(c: Vector2, r: float, n: int) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in n: p.append(c + Vector2.from_angle(TAU * i / n) * r)
	return p

static func _star(c: Vector2, ro: float, ri: float, k: int) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in k * 2:
		var a := -PI / 2.0 + PI * i / k
		p.append(c + Vector2.from_angle(a) * (ro if i % 2 == 0 else ri))
	return p

static func _heart(c: Vector2, s: float) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in 48:
		var t := TAU * i / 48.0
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
		p.append(c + Vector2(x, -y) * s)
	return p

static func _arrow(c: Vector2) -> PackedVector2Array:
	var pts := [Vector2(0, -260), Vector2(170, -60), Vector2(60, -60), Vector2(60, 260), Vector2(-60, 260), Vector2(-60, -60), Vector2(-170, -60)]
	var p := PackedVector2Array()
	for v in pts: p.append(c + v)
	return p

static func _crescent(c: Vector2) -> PackedVector2Array:
	var a := _circle(c, 220.0, 48)
	var b := _circle(c + Vector2(90, -40), 190.0, 48)
	var r := Geometry2D.clip_polygons(a, b)
	return r[0]

static func _key(c: Vector2) -> PackedVector2Array:
	var ring := _circle(c + Vector2(0, -130), 120.0, 36)
	var shaft := PackedVector2Array([c + Vector2(-34, -20), c + Vector2(34, -20), c + Vector2(34, 300), c + Vector2(-34, 300)])
	var t1 := PackedVector2Array([c + Vector2(34, 170), c + Vector2(130, 170), c + Vector2(130, 220), c + Vector2(34, 220)])
	var t2 := PackedVector2Array([c + Vector2(34, 250), c + Vector2(110, 250), c + Vector2(110, 296), c + Vector2(34, 296)])
	var r: PackedVector2Array = Geometry2D.merge_polygons(ring, shaft)[0]
	r = Geometry2D.merge_polygons(r, t1)[0]
	r = Geometry2D.merge_polygons(r, t2)[0]
	return r
