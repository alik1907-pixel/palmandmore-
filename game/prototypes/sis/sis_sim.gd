class_name SisSim
extends RefCounted
## ŞİŞ greybox: deterministic soft-body balloon. One input: hold = inflate.
## Inflating grows area (buoyancy up) but the body gets wider; narrow gaps
## need deflation while momentum carries you through. Spikes and over-inflation pop.

const N := 18                  # ring nodes
const DT := 1.0 / 60.0
const GRAVITY := 520.0
const BUOYANCY := 0.62         # upward accel per unit of (radius - neutral radius)
const R_MIN := 22.0
const R_MAX := 70.0
const R_POP := 64.0            # above this for POP_FRAMES -> pop
const POP_FRAMES := 40
const INFLATE_RATE := 70.0     # px radius per second
const DEFLATE_RATE := 85.0
const R_NEUTRAL := 42.0
const SPRING_K := 0.55
const PRESSURE_K := 0.9
const DAMP := 0.992
const NODE_R := 4.0

var pos: PackedVector2Array
var prev: PackedVector2Array
var target_r := R_NEUTRAL
var over_frames := 0
var frame := 0
var state := "play"            # play | won | popped
var level: Dictionary
var walls: Array = []          # [a, b] segments
var spikes: Array = []         # [a, b] segments (lethal)
var finish_y := 0.0
var winds: Array = []          # [Rect2, float accel_x]
var _near_walls: Array = []
var _near_spikes: Array = []
var best_y := INF
var stall_frames := 0
const STALL_LIMIT := 60 * 8    # no upward progress for 8 s -> stuck (counts as fail)

func _init(lvl: Dictionary) -> void:
	level = lvl
	walls = lvl.walls
	spikes = lvl.spikes
	finish_y = lvl.finish_y
	winds = lvl.get("winds", [])
	pos = PackedVector2Array()
	prev = PackedVector2Array()
	for i in N:
		var a := TAU * i / N
		var p: Vector2 = lvl.start + Vector2(cos(a), sin(a)) * target_r
		pos.append(p)
		prev.append(p)

func center() -> Vector2:
	var c := Vector2.ZERO
	for p in pos:
		c += p
	return c / N

func velocity() -> Vector2:
	var v := Vector2.ZERO
	for i in N:
		v += pos[i] - prev[i]
	return v / N / DT

func radius() -> float:
	return sqrt(absf(_area()) / PI)

func _area() -> float:
	var a := 0.0
	for i in N:
		var p := pos[i]
		var q := pos[(i + 1) % N]
		a += p.x * q.y - q.x * p.y
	return a * 0.5

func step(holding: bool) -> void:
	if state != "play":
		return
	frame += 1
	target_r += (INFLATE_RATE if holding else -DEFLATE_RATE) * DT
	target_r = clamp(target_r, R_MIN, R_MAX)
	over_frames = over_frames + 1 if target_r > R_POP else 0
	if over_frames > POP_FRAMES:
		state = "popped"
		return
	var r := radius()
	var lift := -(GRAVITY * 0.35) - BUOYANCY * GRAVITY * (r - R_NEUTRAL) / 10.0
	var acc := Vector2(0, GRAVITY * 0.35 + lift)
	var c0 := center()
	var vel := velocity()
	for w in winds:
		if (w[0] as Rect2).has_point(c0):
			acc.x += w[1] * pow(r / R_NEUTRAL, 2.0)   # bigger body = bigger sail
	acc.x -= vel.x * 0.9 * (r / R_NEUTRAL)          # air drag
	# Verlet integrate
	for i in N:
		var p := pos[i]
		var v := (p - prev[i]) * DAMP
		prev[i] = p
		pos[i] = p + v + acc * DT * DT
	_gather_near(center(), target_r + 40.0)
	# constraints
	var seg_len := 2.0 * target_r * sin(PI / N)
	var target_area := PI * target_r * target_r
	for _it in 4:
		for i in N:
			var j := (i + 1) % N
			var d := pos[j] - pos[i]
			var l := d.length()
			if l > 0.0001:
				var corr := d * ((l - seg_len) / l) * 0.5 * SPRING_K
				pos[i] += corr
				pos[j] -= corr
		# pressure: push nodes along outward normal
		var da := (target_area - absf(_area())) / (2.0 * PI * maxf(target_r, 1.0))
		var c := center()
		for i in N:
			var n := (pos[i] - c).normalized()
			pos[i] += n * da * PRESSURE_K / 4.0
		_collide()
		if state != "play":
			return
	var cy := center().y
	if cy < finish_y:
		state = "won"
	elif cy < best_y - 4.0:
		best_y = cy
		stall_frames = 0
	else:
		stall_frames += 1
		if stall_frames > STALL_LIMIT:
			state = "stuck"

func _gather_near(c: Vector2, reach: float) -> void:
	_near_walls.clear()
	_near_spikes.clear()
	for w in walls:
		if _seg_dist(c, w[0], w[1]) < reach:
			_near_walls.append(w)
	for sp in spikes:
		if _seg_dist(c, sp[0], sp[1]) < reach:
			_near_spikes.append(sp)

func _collide() -> void:
	for i in N:
		var p := pos[i]
		for s in _near_spikes:
			if _seg_dist(p, s[0], s[1]) < NODE_R + 2.0:
				state = "popped"
				return
		for w in _near_walls:
			var cp := Geometry2D.get_closest_point_to_segment(p, w[0], w[1])
			var d := p - cp
			var l := d.length()
			if l < NODE_R:
				var n := d / l if l > 0.0001 else Vector2.UP
				p = cp + n * NODE_R
				# friction: kill some tangential velocity
				var v := p - prev[i]
				var vn := n * v.dot(n)
				prev[i] = p - (v - vn) * 0.9
		pos[i] = p

func _seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))
