class_name BalloonSim
extends RefCounted
## Deterministic soft-body balloon simulation (fixed 60 Hz, no randomness).
## One input per frame: holding (inflate) or not (deflate).
## Emits per-step `events` (Array of Dictionary) for the view's juice/audio;
## events never feed back into the simulation.

const DT := 1.0 / 60.0

var t: Tuning
var level: Dictionary
var pos := PackedVector2Array()
var prev := PackedVector2Array()
var target_r := 0.0
var over_frames := 0
var frame := 0
var state := "play"            # play | won | popped | stuck
var events: Array = []
var walls: Array = []
var spikes: Array = []
var winds: Array = []
var finish_y := 0.0
var best_y := INF
var stall_frames := 0
var stall_limit_frames := 0       # 0 = never fail for being stuck (real play); validators set a limit
var squeezing := false
var pop_point := Vector2.ZERO
var inputs := PackedByteArray()   # replay: 1 byte per frame
var record_inputs := true

var _near_walls: Array = []
var _near_spikes: Array = []
var _contact_normals: Array = []
var _near_miss_armed := false
var _n := 18

func _init(lvl: Dictionary, tuning: Tuning = null) -> void:
	t = tuning if tuning != null else Tuning.load_default()
	level = lvl
	walls = lvl.walls
	spikes = lvl.spikes
	winds = lvl.winds
	finish_y = lvl.finish_y
	_n = t.nodes
	target_r = t.r_neutral
	for i in _n:
		var p: Vector2 = lvl.start + Vector2.from_angle(TAU * i / _n) * target_r
		pos.append(p)
		prev.append(p)

func center() -> Vector2:
	var c := Vector2.ZERO
	for p in pos:
		c += p
	return c / _n

func velocity() -> Vector2:
	var v := Vector2.ZERO
	for i in _n:
		v += pos[i] - prev[i]
	return v / _n / DT

func radius() -> float:
	return sqrt(absf(_area()) / PI)

func over_ratio() -> float:
	## 0..1 how close we are to popping from over-inflation (for warnings).
	return float(over_frames) / float(t.pop_frames)

func progress() -> float:
	var start_y: float = level.start.y
	return clampf((start_y - center().y) / (start_y - finish_y), 0.0, 1.0)

func _area() -> float:
	var a := 0.0
	for i in _n:
		var p := pos[i]
		var q := pos[(i + 1) % _n]
		a += p.x * q.y - q.x * p.y
	return a * 0.5

func step(holding: bool) -> void:
	events = []
	if state != "play":
		return
	frame += 1
	if record_inputs:
		inputs.append(1 if holding else 0)
	target_r = clampf(target_r + (t.inflate_rate if holding else -t.deflate_rate) * DT, t.r_min, t.r_max)
	over_frames = over_frames + 1 if target_r > t.r_pop else 0
	if over_frames > t.pop_frames and bool(level.get("overpop", true)):
		_pop(center(), "overinflate")
		return
	var r := radius()
	# lift saturates at the pop threshold: the red zone adds sail, not climb
	var lift_r := minf(r, t.r_pop)
	var acc := Vector2(0.0, -t.buoyancy * t.gravity * (lift_r - t.r_neutral) / 10.0)
	var c0 := center()
	var vel := velocity()
	for w in winds:
		if (w.rect as Rect2).has_point(c0):
			acc.x += float(w.accel) * t.wind_scale * pow(r / t.r_neutral, t.sail_exponent)
	acc.x -= vel.x * t.air_drag_x * (r / t.r_neutral)
	acc.y -= vel.y * t.air_drag_y * (r / t.r_neutral)
	for i in _n:
		var p := pos[i]
		var v := (p - prev[i]) * t.damping
		prev[i] = p
		pos[i] = p + v + acc * DT * DT
	_gather_near(center(), target_r + 40.0)
	_contact_normals.clear()
	var seg_len := 2.0 * target_r * sin(PI / _n)
	var target_area := PI * target_r * target_r
	var hit_speed := 0.0
	for _it in 4:
		for i in _n:
			var j := (i + 1) % _n
			var d := pos[j] - pos[i]
			var l := d.length()
			if l > 0.0001:
				var corr := d * ((l - seg_len) / l) * 0.5 * t.spring_k
				pos[i] += corr
				pos[j] -= corr
		var da := (target_area - absf(_area())) / (2.0 * PI * maxf(target_r, 1.0))
		var c := center()
		for i in _n:
			pos[i] += (pos[i] - c).normalized() * da * t.pressure_k / 4.0
		hit_speed = maxf(hit_speed, _collide())
		if state != "play":
			return
	if hit_speed > t.hard_hit_speed:
		events.append({"type": "hit", "speed": hit_speed, "at": center()})
	_detect_squeeze()
	_detect_near_miss()
	var cy := center().y
	if cy < finish_y:
		state = "won"
		events.append({"type": "won"})
	elif cy < best_y - 4.0:
		best_y = cy
		stall_frames = 0
	else:
		stall_frames += 1
		if stall_limit_frames > 0 and stall_frames > stall_limit_frames:
			state = "stuck"
			events.append({"type": "stuck"})

func _pop(at: Vector2, cause: String) -> void:
	state = "popped"
	pop_point = at
	events.append({"type": "pop", "at": at, "cause": cause})

func _gather_near(c: Vector2, reach: float) -> void:
	_near_walls.clear()
	_near_spikes.clear()
	for w in walls:
		if _seg_dist(c, w[0], w[1]) < reach:
			_near_walls.append(w)
	for s in spikes:
		if _seg_dist(c, s[0], s[1]) < reach + t.near_miss_px:
			_near_spikes.append(s)

## Returns the max normal impact speed (px/s) this iteration.
func _collide() -> float:
	var max_hit := 0.0
	for i in _n:
		var p := pos[i]
		for s in _near_spikes:
			if _seg_dist(p, s[0], s[1]) < t.node_radius + 2.0:
				_pop(p, "spike")
				return 0.0
		for w in _near_walls:
			var cp := Geometry2D.get_closest_point_to_segment(p, w[0], w[1])
			var d := p - cp
			var l := d.length()
			if l < t.node_radius:
				var nrm := d / l if l > 0.0001 else Vector2.UP
				p = cp + nrm * t.node_radius
				# rounded lips: touching a segment end nudges the body off the corner
				var a: Vector2 = w[0]
				var b: Vector2 = w[1]
				if cp.is_equal_approx(a) or cp.is_equal_approx(b):
					var away := (cp - (b if cp.is_equal_approx(a) else a)).normalized()
					p += away * t.lip_slip
				var v := p - prev[i]
				var vn := nrm * v.dot(nrm)
				max_hit = maxf(max_hit, -v.dot(nrm) / DT)
				prev[i] = p - (v - vn) * t.wall_friction_keep
				_contact_normals.append(nrm)
		pos[i] = p
	return max_hit

func _detect_squeeze() -> void:
	var now := false
	for a in _contact_normals:
		for b in _contact_normals:
			if (a as Vector2).dot(b) < -0.6:
				now = true
				break
		if now:
			break
	if now and not squeezing:
		events.append({"type": "squeeze", "at": center()})
	squeezing = now

func _detect_near_miss() -> void:
	var closest := INF
	for s in _near_spikes:
		for p in pos:
			closest = minf(closest, _seg_dist(p, s[0], s[1]))
	var close := closest < t.node_radius + 2.0 + t.near_miss_px
	if close:
		_near_miss_armed = true
	elif _near_miss_armed:
		_near_miss_armed = false
		events.append({"type": "near_miss", "at": center()})

func _seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))

## Lightweight copy for look-ahead planning (geometry shared, no replay/events).
func clone() -> BalloonSim:
	var c := BalloonSim.new(level, t)
	c.pos = pos.duplicate()
	c.prev = prev.duplicate()
	c.target_r = target_r
	c.over_frames = over_frames
	c.frame = frame
	c.state = state
	c.best_y = best_y
	c.stall_frames = stall_frames
	c.squeezing = squeezing
	c.record_inputs = false
	return c

## Stable hash of the full physical state (determinism tests / replay validation).
func state_hash() -> int:
	var b := StreamPeerBuffer.new()
	for p in pos:
		b.put_float(p.x)
		b.put_float(p.y)
	b.put_float(target_r)
	b.put_32(frame)
	b.put_utf8_string(state)
	return hash(b.data_array)
