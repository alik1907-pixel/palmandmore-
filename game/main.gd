extends Node2D
## Placeholder boot scene for M0 smoke test.
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color("101820"))
	draw_circle(Vector2(360, 640), 120.0, Color("f2aa4c"))
