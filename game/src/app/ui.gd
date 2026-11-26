class_name UI
extends RefCounted
## Code-drawn UI kit (no image assets): buttons, panels, icons, stars.
## Screens collect buttons during _draw and resolve taps against them.

static var font: Font = null

static func f() -> Font:
	if font == null:
		font = ThemeDB.fallback_font
	return font

static func panel(ci: CanvasItem, r: Rect2, st: ArtStyle, alpha := 0.92) -> void:
	var sh := Rect2(r.position + Vector2(0, 8), r.size)
	_round_rect(ci, sh, 28.0, Color(0, 0, 0, 0.18))
	var bg: Color = st.c.white if st.id != "gece" else Color("1c1a33")
	bg.a = alpha
	_round_rect(ci, r, 28.0, bg)

static func button(ci: CanvasItem, r: Rect2, label: String, st: ArtStyle, primary := false, enabled := true, pressed := false) -> void:
	var base: Color = st.c.finish if primary else (st.c.wall if st.id != "pastel" else Color("7d8bd9"))
	if not enabled:
		base = Color(0.55, 0.55, 0.55)
	var off := Vector2(0, 0 if not pressed else 5)
	_round_rect(ci, Rect2(r.position + Vector2(0, 7), r.size), 24.0, base.darkened(0.35))
	_round_rect(ci, Rect2(r.position + off, r.size), 24.0, base)
	if label != "":
		var size := 40 if primary else 30
		text_center(ci, label, r.get_center() + off + Vector2(0, size * 0.35), size, Color.WHITE)

static func text_center(ci: CanvasItem, s: String, at: Vector2, size: int, col: Color) -> void:
	ci.draw_string(f(), Vector2(at.x - 1000, at.y), s, HORIZONTAL_ALIGNMENT_CENTER, 2000, size, col)

static func text_left(ci: CanvasItem, s: String, at: Vector2, size: int, col: Color) -> void:
	ci.draw_string(f(), at, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

static func _round_rect(ci: CanvasItem, r: Rect2, rad: float, col: Color) -> void:
	## Single polygon (no overlapping pieces → correct with translucent colors).
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var pts := PackedVector2Array()
	var centers := [r.end - Vector2(rad, rad), Vector2(r.position.x + rad, r.end.y - rad), r.position + Vector2(rad, rad), Vector2(r.end.x - rad, r.position.y + rad)]
	for k in 4:
		for i in 7:
			var a := PI * 0.5 * k + PI * 0.5 * i / 6.0
			pts.append(centers[k] + Vector2.from_angle(a) * rad)
	ci.draw_colored_polygon(pts, col)

static func text_wrap(ci: CanvasItem, s: String, at: Vector2, width: float, size: int, col: Color) -> void:
	ci.draw_multiline_string(f(), at, s, HORIZONTAL_ALIGNMENT_LEFT, width, size, 2, col)

static func star(ci: CanvasItem, c: Vector2, r: float, filled: bool, col := Color("ffc93c")) -> void:
	var p := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + PI * i / 5.0
		p.append(c + Vector2.from_angle(a) * (r if i % 2 == 0 else r * 0.45))
	if filled:
		ci.draw_colored_polygon(p, col)
	else:
		ci.draw_colored_polygon(p, Color(0, 0, 0, 0.15))
	var o := p.duplicate(); o.append(p[0])
	ci.draw_polyline(o, col.darkened(0.35) if filled else Color(0, 0, 0, 0.25), 2.0)

static func icon(ci: CanvasItem, kind: String, c: Vector2, s: float, col: Color) -> void:
	match kind:
		"home":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s, 0), c + Vector2(0, -s), c + Vector2(s, 0)]), col)
			ci.draw_rect(Rect2(c + Vector2(-s * 0.65, 0), Vector2(s * 1.3, s * 0.8)), col)
		"gear":
			for i in 8:
				var a := TAU * i / 8.0
				ci.draw_line(c + Vector2.from_angle(a) * s * 0.5, c + Vector2.from_angle(a) * s, col, s * 0.32)
			ci.draw_circle(c, s * 0.62, col)
			ci.draw_circle(c, s * 0.26, Color(0, 0, 0, 0.35))
		"retry":
			ci.draw_arc(c, s * 0.7, -PI * 0.2, PI * 1.5, 20, col, s * 0.25)
			var tip := c + Vector2.from_angle(-PI * 0.2) * s * 0.7
			ci.draw_colored_polygon(PackedVector2Array([tip + Vector2(-s * 0.35, -s * 0.3), tip + Vector2(s * 0.45, -s * 0.15), tip + Vector2(0, s * 0.5)]), col)
		"next":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.5, -s * 0.8), c + Vector2(s * 0.8, 0), c + Vector2(-s * 0.5, s * 0.8)]), col)
		"share":
			for p in [c + Vector2(s * 0.6, -s * 0.6), c + Vector2(-s * 0.6, 0), c + Vector2(s * 0.6, s * 0.6)]:
				ci.draw_circle(p, s * 0.24, col)
			ci.draw_line(c + Vector2(s * 0.6, -s * 0.6), c + Vector2(-s * 0.6, 0), col, s * 0.12)
			ci.draw_line(c + Vector2(-s * 0.6, 0), c + Vector2(s * 0.6, s * 0.6), col, s * 0.12)
		"lock":
			ci.draw_arc(c + Vector2(0, -s * 0.2), s * 0.42, PI, TAU, 12, col, s * 0.16)
			ci.draw_rect(Rect2(c + Vector2(-s * 0.6, -s * 0.2), Vector2(s * 1.2, s * 0.95)), col)
		"flame":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.6, 0), c + Vector2(s * 0.45, s * 0.6), c + Vector2(0, s * 0.8), c + Vector2(-s * 0.45, s * 0.6), c + Vector2(-s * 0.6, 0)]), Color("ff7a1a"))
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s * 0.2), c + Vector2(s * 0.3, s * 0.3), c + Vector2(0, s * 0.65), c + Vector2(-s * 0.3, s * 0.3)]), Color("ffd23c"))
		"film":
			ci.draw_rect(Rect2(c - Vector2(s * 0.8, s * 0.55), Vector2(s * 1.6, s * 1.1)), col)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.2, -s * 0.3), c + Vector2(s * 0.35, 0), c + Vector2(-s * 0.2, s * 0.3)]), Color(0, 0, 0, 0.55))
		"calendar":
			ci.draw_rect(Rect2(c - Vector2(s * 0.8, s * 0.6), Vector2(s * 1.6, s * 1.4)), col)
			ci.draw_rect(Rect2(c - Vector2(s * 0.8, s * 0.6), Vector2(s * 1.6, s * 0.35)), col.darkened(0.3))
		"palette":
			ci.draw_circle(c, s * 0.85, col)
			for i in 4:
				ci.draw_circle(c + Vector2.from_angle(TAU * i / 4.0 + 0.4) * s * 0.45, s * 0.16, [Color("ff6b6b"), Color("ffd23c"), Color("4dabf7"), Color("51cf66")][i])
		"balloon":
			ci.draw_circle(c + Vector2(0, -s * 0.15), s * 0.7, col)
			ci.draw_line(c + Vector2(0, s * 0.55), c + Vector2(s * 0.1, s * 1.0), col, 3.0)
		"noads":
			ci.draw_arc(c, s * 0.8, 0, TAU, 24, col, s * 0.18)
			ci.draw_line(c + Vector2(-s * 0.55, -s * 0.55), c + Vector2(s * 0.55, s * 0.55), col, s * 0.18)
			text_center(ci, "AD", c + Vector2(0, s * 0.22), int(s * 0.7), col)

static func hit(buttons: Array, p: Vector2) -> String:
	for i in range(buttons.size() - 1, -1, -1):
		var b: Dictionary = buttons[i]
		if (b.rect as Rect2).grow(10.0).has_point(p) and b.get("enabled", true):
			return b.id
	return ""
