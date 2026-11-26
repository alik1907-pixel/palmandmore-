extends SceneTree
## Renders the app icon procedurally (needs a display: run under xvfb with opengl3).
## Outputs: data/icon.png (512), data/icon_192.png, data/icon_fg_432.png, data/icon_bg_432.png,
##          ../media/store/icon_512.png
const PAPER := Color("f4ead4")
const TEAL := Color("1f6f78")
const TEAL_D := Color("123f45")
const ORANGE := Color("f6b33c")
const INK := Color("2b2522")
const RED := Color("e8553e")

class Painter extends Node2D:
	var layer := "full"     # full | fg | bg
	var s := 1024.0
	func _draw() -> void:
		var k := s / 1024.0
		if layer != "fg":
			draw_rect(Rect2(0, 0, s, s), PAPER)
			for i in 400:
				var p := Vector2(fposmod(i * 97.3, 1024.0), fposmod(i * 211.7, 1024.0)) * k
				draw_circle(p, 1.6 * k, Color(0, 0, 0, 0.05))
			# funnel walls (paper strips with shadow)
			for side in [-1.0, 1.0]:
				var a := Vector2(512 + side * 520, 1010) * k
				var b := Vector2(512 + side * 150, 760) * k
				draw_line(a + Vector2(14, 18) * k, b + Vector2(14, 18) * k, Color(0, 0, 0, 0.18), 70 * k)
				draw_line(a, b, TEAL_D, 74 * k)
				draw_line(a, b, TEAL, 58 * k)
				# spikes on the outer part
				var d := (b - a).normalized()
				var n: Vector2 = Vector2(-d.y, d.x) * (-side)
				for j in 3:
					var p0 := a + d * (60 + j * 70) * k
					var p1 := p0 + d * 60 * k
					var tip: Vector2 = (p0 + p1) * 0.5 - n * 60 * k
					draw_colored_polygon(PackedVector2Array([p0, p1, tip]), RED)
		if layer != "bg":
			var c := Vector2(512, 470) * k
			var rx := 300.0 * k
			var ry := 340.0 * k
			var body := PackedVector2Array()
			for i in 64:
				var a2 := TAU * i / 64.0
				var squeeze := 1.0 - 0.12 * pow(maxf(sin(a2), 0.0), 3.0)   # pinched toward the gap
				body.append(c + Vector2(cos(a2) * rx * squeeze, sin(a2) * ry))
			var sh := PackedVector2Array()
			for p in body: sh.append(p + Vector2(18, 24) * k)
			draw_colored_polygon(sh, Color(0, 0, 0, 0.18))
			draw_colored_polygon(body, ORANGE)
			var o := body.duplicate(); o.append(body[0])
			draw_polyline(o, INK, 26 * k, true)
			draw_arc(c + Vector2(-70, -90) * k, 190 * k, PI * 1.05, PI * 1.45, 24, Color(1, 1, 1, 0.65), 40 * k)
			for sx in [-1.0, 1.0]:
				var e := c + Vector2(sx * 105, -40) * k
				draw_circle(e, 62 * k, Color("fffaf0"))
				draw_circle(e + Vector2(0, -18) * k, 30 * k, INK)
			draw_arc(c + Vector2(0, 95) * k, 60 * k, 0.35, PI - 0.35, 16, INK, 20 * k)
			# motion lines
			for j in 3:
				var x := (380 + j * 130) * k
				draw_line(Vector2(x, 900 * k), Vector2(x, 980 * k), Color(INK, 0.5), 14 * k)

func _init() -> void:
	call_deferred("_run")

func _render(layer: String, size: int, transparent: bool) -> Image:
	var vp := SubViewport.new()
	vp.size = Vector2i(size, size)
	vp.transparent_bg = transparent
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var p := Painter.new()
	p.layer = layer
	p.s = size
	vp.add_child(p)
	root.add_child(vp)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	vp.queue_free()
	return img

func _run() -> void:
	var full: Image = await _render("full", 1024, false)
	for pair in [[512, "res://data/icon.png"], [192, "res://data/icon_192.png"]]:
		var im := full.duplicate()
		im.resize(pair[0], pair[0], Image.INTERPOLATE_LANCZOS)
		im.save_png(pair[1])
	var store := full.duplicate()
	store.resize(512, 512, Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../media/store"))
	store.save_png(ProjectSettings.globalize_path("res://../media/store/icon_512.png"))
	var fg: Image = await _render("fg", 432, true)
	fg.save_png("res://data/icon_fg_432.png")
	var bg: Image = await _render("bg", 432, false)
	bg.save_png("res://data/icon_bg_432.png")
	print("ICON_DONE")
	quit()
