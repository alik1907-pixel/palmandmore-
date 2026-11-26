class_name ArtStyle
extends RefCounted
## Visual themes. One is the default look; the others are unlockable cosmetics.
## Everything is drawn in code (no image assets).

const IDS := ["kagit", "gece", "pastel"]
const DEFAULT := "kagit"

var id := ""
var name := ""
var c := {}               # palette
var wall_width := 10.0
var wall_glow := false
var wall_shadow := Vector2.ZERO
var balloon_outline := 0.0
var halftone := false
var stars := false
var bg := {}              # shader uniforms

## Stars needed to unlock a theme for free (the theme pack IAP unlocks all).
static func unlock_stars(style_id: String) -> int:
	match style_id:
		"gece": return 25
		"pastel": return 40
	return 0

static func make(style_id: String) -> ArtStyle:
	var s := ArtStyle.new()
	s.id = style_id
	match style_id:
		"gece":
			s.name = "Neon Gece"
			s.c = {"wall": Color("6ff7ff"), "wall_edge": Color("1c8cff"), "spike": Color("ff3df2"), "spike_dark": Color("a1009a"),
				"balloon": Color("ffb547"), "hot": Color("ff3b3b"), "finish": Color("7effa1"), "wind": Color(0.55, 0.85, 1.0),
				"ink": Color("12101f"), "white": Color("fffaf0"), "ui": Color("ffffff"), "ui_dim": Color(1, 1, 1, 0.55)}
			s.wall_width = 7.0
			s.wall_glow = true
			s.stars = true
			s.bg = {"top_color": Color("1d1b3a"), "bottom_color": Color("070f1c"), "grain": 0.02, "fibres": 0.0, "vignette": 0.6}
		"pastel":
			s.name = "Pastel Gün"
			s.c = {"wall": Color("ffffff"), "wall_edge": Color("c9d3f2"), "spike": Color("ff6b81"), "spike_dark": Color("e0485f"),
				"balloon": Color("ff9f43"), "hot": Color("ff3b3b"), "finish": Color("3cc983"), "wind": Color(1, 1, 1),
				"ink": Color("2d2a4a"), "white": Color("ffffff"), "ui": Color("2d2a4a"), "ui_dim": Color(0.18, 0.16, 0.29, 0.55)}
			s.wall_width = 16.0
			s.wall_shadow = Vector2(0, 8)
			s.bg = {"top_color": Color("a9d8ff"), "bottom_color": Color("ffdbe7"), "grain": 0.015, "fibres": 0.0, "vignette": 0.15}
		_:
			s.id = "kagit"
			s.name = "Kâğıt Kesik"
			s.c = {"wall": Color("1f6f78"), "wall_edge": Color("123f45"), "spike": Color("e8553e"), "spike_dark": Color("a8321f"),
				"balloon": Color("f6b33c"), "hot": Color("e8553e"), "finish": Color("2f9e6e"), "wind": Color("1f6f78"),
				"ink": Color("2b2522"), "white": Color("fffaf0"), "ui": Color("2b2522"), "ui_dim": Color(0.17, 0.15, 0.13, 0.55)}
			s.wall_width = 14.0
			s.wall_shadow = Vector2(6, 9)
			s.balloon_outline = 4.0
			s.halftone = true
			s.bg = {"top_color": Color("f4ead4"), "bottom_color": Color("e6d5b1"), "grain": 0.03, "fibres": 0.06, "vignette": 0.3}
	return s

func apply_background(mat: ShaderMaterial) -> void:
	for k in bg:
		mat.set_shader_parameter(k, bg[k])

## Draws a wall segment in this style onto `ci`.
func draw_wall(ci: CanvasItem, a: Vector2, b: Vector2) -> void:
	if wall_shadow != Vector2.ZERO:
		ci.draw_line(a + wall_shadow, b + wall_shadow, Color(0, 0, 0, 0.18), wall_width + 2.0)
	if wall_glow:
		ci.draw_line(a, b, Color(c.wall_edge, 0.18), wall_width * 4.0)
		ci.draw_line(a, b, Color(c.wall_edge, 0.35), wall_width * 2.2)
		ci.draw_line(a, b, c.wall, wall_width)
		return
	ci.draw_line(a, b, c.wall_edge, wall_width + 4.0)
	ci.draw_line(a, b, c.wall, wall_width)
	ci.draw_circle(a, (wall_width + 4.0) * 0.5, c.wall_edge)
	ci.draw_circle(b, (wall_width + 4.0) * 0.5, c.wall_edge)
	ci.draw_circle(a, wall_width * 0.5, c.wall)
	ci.draw_circle(b, wall_width * 0.5, c.wall)

func draw_spikes(ci: CanvasItem, a: Vector2, b: Vector2) -> void:
	var d := b - a
	var n := maxi(int(d.length() / 20.0), 1)
	var tdir := d.normalized()
	var nrm := Vector2(-tdir.y, tdir.x)
	var step := d.length() / n
	if wall_glow:
		ci.draw_line(a, b, Color(c.spike, 0.25), 30.0)
	for i in n:
		var p0 := a + tdir * (i * step)
		var p1 := p0 + tdir * step
		var mid := (p0 + p1) * 0.5
		for side in [1.0, -1.0]:
			var tri := PackedVector2Array([p0, p1, mid + nrm * 16.0 * side])
			if wall_shadow != Vector2.ZERO:
				var sh := PackedVector2Array()
				for v in tri: sh.append(v + wall_shadow * 0.6)
				ci.draw_colored_polygon(sh, Color(0, 0, 0, 0.15))
			ci.draw_colored_polygon(tri, c.spike if side > 0.0 else c.spike_dark)
			if balloon_outline > 0.0:
				var o := tri.duplicate(); o.append(tri[0])
				ci.draw_polyline(o, c.ink, 2.0)
