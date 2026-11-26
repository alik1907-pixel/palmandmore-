class_name DalSim
extends RefCounted
## DALGA greybox: tap the pond to drop a stone. Ripples (2D wave equation on a
## grid) push a floating lantern by the surface slope. Interference, reflections
## off rocks and a limited number of stones make it a physics puzzle.
## Risk-reward: a stone dropped close pushes hard but a steep wave capsizes the lantern.

const CELL := 16.0
const GW := 45
const GH := 80
const C2 := 0.24
const DAMP := 0.99
const DROP_AMP := 9.0
const PUSH := 1100.0
const DRAG := 0.99
const CAPSIZE_SLOPE := 3.9
const GOAL_R := 44.0

var h := PackedFloat32Array()
var hp := PackedFloat32Array()
var wall := PackedByteArray()
var lantern := Vector2.ZERO
var vel := Vector2.ZERO
var goal := Vector2.ZERO
var stones := 0
var stones_used := 0
var frame := 0
var idle_frames := 0
var state := "play"   # play | won | lost(capsized/out of stones)
var reason := ""
var level: Dictionary

func _init(lvl: Dictionary) -> void:
	level = lvl
	h.resize(GW * GH)
	hp.resize(GW * GH)
	wall.resize(GW * GH)
	for x in GW:
		for y in GH:
			var edge := x == 0 or y == 0 or x == GW - 1 or y == GH - 1
			wall[y * GW + x] = 1 if edge else 0
	for r in lvl.rocks:
		var rect: Rect2 = r
		for x in range(int(rect.position.x / CELL), int(rect.end.x / CELL) + 1):
			for y in range(int(rect.position.y / CELL), int(rect.end.y / CELL) + 1):
				if x >= 0 and y >= 0 and x < GW and y < GH:
					wall[y * GW + x] = 1
	lantern = lvl.start
	goal = lvl.goal
	stones = lvl.stones

func is_wall_at(p: Vector2) -> bool:
	var x := int(p.x / CELL)
	var y := int(p.y / CELL)
	if x < 0 or y < 0 or x >= GW or y >= GH:
		return true
	return wall[y * GW + x] == 1

func drop(p: Vector2) -> void:
	if state != "play" or stones <= 0 or is_wall_at(p):
		return
	stones -= 1
	stones_used += 1
	idle_frames = 0
	var cx := p.x / CELL
	var cy := p.y / CELL
	for y in range(int(cy) - 3, int(cy) + 4):
		for x in range(int(cx) - 3, int(cx) + 4):
			if x <= 0 or y <= 0 or x >= GW - 1 or y >= GH - 1:
				continue
			var d2 := (x - cx) * (x - cx) + (y - cy) * (y - cy)
			var i := y * GW + x
			if wall[i] == 0:
				h[i] += DROP_AMP * exp(-d2 / 2.2)

func sample(p: Vector2) -> float:
	var fx: float = clamp(p.x / CELL, 0.0, GW - 1.001)
	var fy: float = clamp(p.y / CELL, 0.0, GH - 1.001)
	var x := int(fx)
	var y := int(fy)
	var tx := fx - x
	var ty := fy - y
	var i := y * GW + x
	var a := lerpf(h[i], h[i + 1], tx)
	var b := lerpf(h[i + GW], h[i + GW + 1], tx)
	return lerpf(a, b, ty)

func step() -> void:
	if state != "play":
		return
	frame += 1
	var n := PackedFloat32Array()
	n.resize(GW * GH)
	for y in range(1, GH - 1):
		var row := y * GW
		for x in range(1, GW - 1):
			var i := row + x
			if wall[i] == 1:
				continue
			var c := h[i]
			var lap := h[i - 1] + h[i + 1] + h[i - GW] + h[i + GW] - 4.0 * c
			n[i] = (2.0 * c - hp[i] + C2 * lap) * DAMP
	hp = h
	h = n
	# lantern rides the slope (downhill = away from a fresh depression's rim)
	var e := CELL * 0.5
	var gx := (sample(lantern + Vector2(e, 0)) - sample(lantern - Vector2(e, 0))) / (2.0 * e) * CELL
	var gy := (sample(lantern + Vector2(0, e)) - sample(lantern - Vector2(0, e))) / (2.0 * e) * CELL
	var slope := Vector2(gx, gy)
	if slope.length() > CAPSIZE_SLOPE:
		state = "lost"
		reason = "capsized"
		return
	vel += -slope * PUSH / 60.0
	vel *= DRAG
	var nxt := lantern + vel / 60.0
	if is_wall_at(Vector2(nxt.x, lantern.y)):
		vel.x = -vel.x * 0.5
		nxt.x = lantern.x
	if is_wall_at(Vector2(nxt.x, nxt.y)):
		vel.y = -vel.y * 0.5
		nxt.y = lantern.y
	lantern = nxt
	if lantern.distance_to(goal) < GOAL_R:
		state = "won"
		return
	idle_frames = idle_frames + 1 if vel.length() < 6.0 else 0
	if stones <= 0 and idle_frames > 90:
		state = "lost"
		reason = "out_of_stones"
	if frame > 60 * 50:
		state = "lost"
		reason = "timeout"
