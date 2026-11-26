class_name Skins
extends RefCounted
## Balloon cosmetics, all procedural. Patterns are clipped to the balloon outline
## with Geometry2D so they deform with the soft body.
## Unlock: stars / daily streak / rewarded ad / IAP pack / coins (shop).

const EARNED := ["classic", "stripes", "dots", "melon", "stars", "planet", "ghost", "gold", "rainbow", "cat"]
## Coin shop: base colour, pattern, pattern colour, price.
const SHOP := {
	"mint": {"base": "7fe0c3", "pattern": "plain", "pcol": "ffffff", "price": 150},
	"berry": {"base": "c2185b", "pattern": "dots", "pcol": "ffffff", "price": 200},
	"lemon": {"base": "fff176", "pattern": "dots", "pcol": "f9a825", "price": 200},
	"candy": {"base": "ff8fb1", "pattern": "stripes", "pcol": "ffffff", "price": 250},
	"grape": {"base": "7e57c2", "pattern": "dots", "pcol": "b39ddb", "price": 250},
	"lava": {"base": "ff5722", "pattern": "diag", "pcol": "ffc107", "price": 300},
	"ocean": {"base": "1e88e5", "pattern": "waves", "pcol": "90caf9", "price": 300},
	"zebra": {"base": "f5f5f5", "pattern": "stripes", "pcol": "222222", "price": 400},
	"pumpkin": {"base": "fb8c00", "pattern": "ribs", "pcol": "e65100", "price": 450},
	"frog": {"base": "66bb6a", "pattern": "frog", "pcol": "ffffff", "price": 500},
	"panda": {"base": "f5f5f5", "pattern": "panda", "pcol": "222222", "price": 600},
	"disco": {"base": "9c27b0", "pattern": "sparkle", "pcol": "ffffff", "price": 1200},
}
const ALL := ["classic", "stripes", "dots", "melon", "stars", "planet", "ghost", "gold", "rainbow", "cat",
	"mint", "berry", "lemon", "candy", "grape", "lava", "ocean", "zebra", "pumpkin", "frog", "panda", "disco"]

static func unlock_rule(skin: String) -> Dictionary:
	if SHOP.has(skin):
		return {"coins": int(SHOP[skin].price)}
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
	if SHOP.has(skin):
		return Color(String(SHOP[skin].base))
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

static func _band(c: Vector2, r: float, y: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(c.x - r * 2, y), Vector2(c.x + r * 2, y), Vector2(c.x + r * 2, y + h), Vector2(c.x - r * 2, y + h)])

static func _fill(ci: CanvasItem, shapes: Array, body: PackedVector2Array, col: Color) -> void:
	for s in shapes:
		for poly in _clip(s, body):
			ci.draw_colored_polygon(poly, col)

## Draws the pattern layer over an already-filled body.
static func draw_pattern(ci: CanvasItem, skin: String, body: PackedVector2Array, c: Vector2, r: float, t: float) -> void:
	if SHOP.has(skin):
		_draw_shop(ci, SHOP[skin], body, c, r, t)
		return
	var shapes: Array = []
	var col := Color.WHITE
	match skin:
		"stripes":
			col = Color(1, 1, 1, 0.55)
			for k in range(-3, 4):
				shapes.append(_band(c, r, c.y + k * r * 0.42, r * 0.18))
		"dots":
			col = Color(1, 1, 1, 0.6)
			for k in 9:
				shapes.append(_circle(c + Vector2.from_angle(TAU * k / 9.0 + 0.4) * r * (0.45 + 0.3 * (k % 2)), r * 0.11))
		"melon":
			col = Color("2d7a36")
			for k in range(-3, 4):
				var x := c.x + k * r * 0.36
				shapes.append(PackedVector2Array([Vector2(x - r * 0.06, c.y - r * 2), Vector2(x + r * 0.06, c.y - r * 2), Vector2(x + r * 0.06, c.y + r * 2), Vector2(x - r * 0.06, c.y + r * 2)]))
		"stars":
			col = Color(1, 1, 0.8, 0.9)
			for k in 12:
				shapes.append(_circle(c + Vector2.from_angle(TAU * k / 12.0 + t * 0.2) * r * (0.3 + 0.5 * fposmod(k * 0.37, 1.0)), r * 0.05, 5))
		"planet":
			col = Color("f6d365")
			shapes.append(PackedVector2Array([Vector2(c.x - r * 2, c.y + r * 0.05), Vector2(c.x + r * 2, c.y - r * 0.35), Vector2(c.x + r * 2, c.y - r * 0.15), Vector2(c.x - r * 2, c.y + r * 0.25)]))
		"rainbow":
			var cols := [Color("ff6b6b"), Color("ffb347"), Color("ffe66d"), Color("6bd17a"), Color("4dabf7"), Color("9775fa")]
			for k in cols.size():
				var h := 2.0 * r / cols.size()
				_fill(ci, [_band(c, r, c.y - r + k * h, h + 1.0)], body, cols[k])
			return
		"gold":
			var sh := 0.5 + 0.5 * sin(t * 3.0)
			ci.draw_arc(c + Vector2(r * 0.2, r * 0.1), r * 0.55, -0.4, 0.9, 10, Color(1, 1, 1, 0.25 + 0.3 * sh), r * 0.1)
			return
		"ghost":
			for k in 3:
				ci.draw_circle(Vector2(c.x + (k - 1) * r * 0.55, c.y + r * 0.95), r * 0.24, Color("e9eef7"))
			return
		"cat":
			_ears(ci, c, r, Color("f0a35e"), Color("f0a35e"))
			return
	_fill(ci, shapes, body, col)

static func _ears(ci: CanvasItem, c: Vector2, r: float, outer: Color, inner: Color) -> void:
	for side in [-1.0, 1.0]:
		var base: Vector2 = c + Vector2(side * r * 0.5, -r * 0.78)
		ci.draw_colored_polygon(PackedVector2Array([base + Vector2(-r * 0.22, r * 0.12), base + Vector2(r * 0.22, r * 0.12), base + Vector2(side * r * 0.05, -r * 0.38)]), outer)
		if inner != outer:
			ci.draw_circle(base + Vector2(0, -r * 0.04), r * 0.08, inner)

static func _draw_shop(ci: CanvasItem, d: Dictionary, body: PackedVector2Array, c: Vector2, r: float, t: float) -> void:
	var pc := Color(String(d.pcol))
	match String(d.pattern):
		"stripes":
			var shapes: Array = []
			for k in range(-3, 4):
				shapes.append(_band(c, r, c.y + k * r * 0.42, r * 0.2))
			_fill(ci, shapes, body, pc)
		"dots":
			var shapes2: Array = []
			for k in 10:
				shapes2.append(_circle(c + Vector2.from_angle(TAU * k / 10.0 + 0.3) * r * (0.35 + 0.35 * (k % 2)), r * 0.12))
			_fill(ci, shapes2, body, pc)
		"diag":
			var shapes3: Array = []
			for k in range(-4, 5):
				var x := c.x + k * r * 0.45
				shapes3.append(PackedVector2Array([Vector2(x - r, c.y - r * 2), Vector2(x - r + r * 0.18, c.y - r * 2), Vector2(x + r + r * 0.18, c.y + r * 2), Vector2(x + r, c.y + r * 2)]))
			_fill(ci, shapes3, body, pc)
		"waves":
			var shapes4: Array = []
			for k in range(-2, 3):
				var y0 := c.y + k * r * 0.5
				var wave := PackedVector2Array()
				for i in 13:
					var x := c.x - r * 1.2 + i * r * 0.2
					wave.append(Vector2(x, y0 + sin(i * 0.9 + t * 2.0) * r * 0.08))
				for i in range(12, -1, -1):
					var x2 := c.x - r * 1.2 + i * r * 0.2
					wave.append(Vector2(x2, y0 + r * 0.14 + sin(i * 0.9 + t * 2.0) * r * 0.08))
				shapes4.append(wave)
			_fill(ci, shapes4, body, pc)
		"ribs":
			for k in range(-2, 3):
				ci.draw_arc(c + Vector2(k * r * 0.12, 0), r * (0.98 - absf(k) * 0.05), PI * 0.5 - 0.9, PI * 0.5 + 0.9, 10, Color(pc, 0.7), 3.0)
				ci.draw_arc(c + Vector2(k * r * 0.12, 0), r * (0.98 - absf(k) * 0.05), -PI * 0.5 - 0.9, -PI * 0.5 + 0.9, 10, Color(pc, 0.7), 3.0)
			ci.draw_rect(Rect2(c + Vector2(-r * 0.08, -r * 1.12), Vector2(r * 0.16, r * 0.22)), Color("5d4037"))
		"frog":
			for side in [-1.0, 1.0]:
				var e: Vector2 = c + Vector2(side * r * 0.42, -r * 0.85)
				ci.draw_circle(e, r * 0.26, Color("66bb6a"))
				ci.draw_circle(e, r * 0.18, Color.WHITE)
				ci.draw_circle(e + Vector2(0, r * 0.03), r * 0.09, Color("1b1b24"))
		"panda":
			_ears(ci, c, r, pc, pc)
			for side in [-1.0, 1.0]:
				var patch: Vector2 = c + Vector2(side * r * 0.32, -r * 0.1)
				_fill(ci, [_circle(patch, r * 0.28, 12)], body, pc)
		"sparkle":
			var cols := [Color("ff4081"), Color("ffd740"), Color("69f0ae"), Color("40c4ff"), Color("ffffff")]
			for k in 14:
				var a := TAU * k / 14.0 + t * 0.8
				var p := c + Vector2.from_angle(a) * r * (0.25 + 0.55 * fposmod(k * 0.61, 1.0))
				var tw := 0.5 + 0.5 * sin(t * 6.0 + k)
				_fill(ci, [_circle(p, r * (0.05 + 0.04 * tw), 6)], body, cols[k % cols.size()])
		_:
			pass
