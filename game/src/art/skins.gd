class_name Skins
extends RefCounted
## Balloon cosmetics, all procedural. Patterns are clipped to the balloon outline
## with Geometry2D so they deform with the soft body.

const ALL := ["classic", "stripes", "dots", "melon", "stars", "planet", "ghost", "gold", "rainbow", "cat"]

static func unlock_rule(skin: String) -> Dictionary:
	match skin:
		"classic": return {"stars": 0}
		"stripes": return {"stars": 6}
		"dots": return {"stars": 12}
		"melon": return {"stars": 18}
		"stars": return {"streak": 3}
		"planet": return {"stars": 30}
		"gold": return {"streak": 7}
		"cat": return {"stars": 40}
		"ghost": return {"ad": true}
		"rainbow": return {"iap": "cosmetic_pack"}
	return {}

static func base_color(skin: String, style: ArtStyle) -> Color:
	match skin:
		"melon": return Color("3fa34d")
		"stars": return Color("2b3a8c")
		"planet": return Color("8e6bd8")
		"ghost": return Color("e9eef7")
		"gold": return Color("f2c230")
		"rainbow": return Color("ff6b6b")
		"cat": return Color("f0a35e")
	return style.c.balloon

static func _clip(shape: PackedVector2Array, body: PackedVector2Array) -> Array:
	return Geometry2D.intersect_polygons(shape, body)

static func _circle(c: Vector2, r: float, n := 10) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in n:
		p.append(c + Vector2.from_angle(TAU * i / n) * r)
	return p

## Draws the pattern layer over an already-filled body.
static func draw_pattern(ci: CanvasItem, skin: String, body: PackedVector2Array, c: Vector2, r: float, t: float) -> void:
	var shapes: Array = []
	var col := Color.WHITE
	match skin:
		"stripes":
			col = Color(1, 1, 1, 0.55)
			for k in range(-3, 4):
				var y := c.y + k * r * 0.42
				shapes.append(PackedVector2Array([Vector2(c.x - r * 2, y), Vector2(c.x + r * 2, y), Vector2(c.x + r * 2, y + r * 0.18), Vector2(c.x - r * 2, y + r * 0.18)]))
		"dots":
			col = Color(1, 1, 1, 0.6)
			for k in 9:
				var a := TAU * k / 9.0 + 0.4
				shapes.append(_circle(c + Vector2.from_angle(a) * r * (0.45 + 0.3 * (k % 2)), r * 0.11))
		"melon":
			col = Color("2d7a36")
			for k in range(-3, 4):
				var x := c.x + k * r * 0.36
				shapes.append(PackedVector2Array([Vector2(x - r * 0.06, c.y - r * 2), Vector2(x + r * 0.06, c.y - r * 2), Vector2(x + r * 0.06, c.y + r * 2), Vector2(x - r * 0.06, c.y + r * 2)]))
		"stars":
			col = Color(1, 1, 0.8, 0.9)
			for k in 12:
				var a := TAU * k / 12.0 + t * 0.2
				shapes.append(_circle(c + Vector2.from_angle(a) * r * (0.3 + 0.5 * fposmod(k * 0.37, 1.0)), r * 0.05, 5))
		"planet":
			col = Color("f6d365")
			shapes.append(PackedVector2Array([Vector2(c.x - r * 2, c.y + r * 0.05), Vector2(c.x + r * 2, c.y - r * 0.35), Vector2(c.x + r * 2, c.y - r * 0.15), Vector2(c.x - r * 2, c.y + r * 0.25)]))
		"rainbow":
			var cols := [Color("ff6b6b"), Color("ffb347"), Color("ffe66d"), Color("6bd17a"), Color("4dabf7"), Color("9775fa")]
			for k in cols.size():
				var y0 := c.y - r + k * (2.0 * r / cols.size())
				var band := PackedVector2Array([Vector2(c.x - r * 2, y0), Vector2(c.x + r * 2, y0), Vector2(c.x + r * 2, y0 + 2.0 * r / cols.size() + 1), Vector2(c.x - r * 2, y0 + 2.0 * r / cols.size() + 1)])
				for poly in _clip(band, body):
					ci.draw_colored_polygon(poly, cols[k])
			return
		"gold":
			var sh := 0.5 + 0.5 * sin(t * 3.0)
			ci.draw_arc(c + Vector2(r * 0.2, r * 0.1), r * 0.55, -0.4, 0.9, 10, Color(1, 1, 1, 0.25 + 0.3 * sh), r * 0.1)
			return
		"ghost":
			for k in 3:
				var x := c.x + (k - 1) * r * 0.55
				ci.draw_circle(Vector2(x, c.y + r * 0.95), r * 0.24, Color("e9eef7"))
			return
		"cat":
			for side in [-1.0, 1.0]:
				var base := c + Vector2(side * r * 0.5, -r * 0.78)
				ci.draw_colored_polygon(PackedVector2Array([base + Vector2(-r * 0.22, r * 0.12), base + Vector2(r * 0.22, r * 0.12), base + Vector2(side * r * 0.05, -r * 0.38)]), Color("f0a35e"))
			return
	for s in shapes:
		for poly in _clip(s, body):
			ci.draw_colored_polygon(poly, col)
