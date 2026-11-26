class_name BalloonBot
extends RefCounted
## Heuristic player used for level validation and autoplay videos.
## skill 0..1 → reaction delay (14→2 frames) and input noise (18%→1%).
## A population of skills approximates a player population; it is NOT a human.

var skill := 0.5
var rng := RandomNumberGenerator.new()
var _queue: Array = []
var _delay := 0
var _drop := 0

func _init(p_skill: float, seed_v: int) -> void:
	skill = p_skill
	rng.seed = seed_v
	_delay = int(lerpf(14.0, 2.0, skill))

func decide(sim: BalloonSim) -> bool:
	var c := sim.center()
	var v := sim.velocity()
	var r := sim.radius()
	var t := sim.t
	var want := v.y > -150.0
	var gate = _next_gate(sim, c)
	var aim_x := c.x
	if gate != null:
		aim_x = gate.x
		var dist: float = c.y - gate.y
		var fits: bool = r * 2.0 < gate.gap * 0.9
		var in_throat: bool = c.y < gate.y + 10.0 and c.y > gate.y - gate.throat - 10.0
		# release just in time: time to shrink to fit × current climb speed
		var fit_r: float = gate.gap * 0.42
		var t_fit: float = maxf(r - fit_r, 0.0) / t.deflate_rate + float(_delay) / 60.0
		var lead: float = absf(minf(v.y, 0.0)) * t_fit + 25.0
		if not fits and dist < lead:
			want = false
		elif not fits and dist < lead + 140.0:
			want = v.y > -320.0     # build speed for the squeeze
		if gate.spiked and dist < 320.0 and absf(gate.x - c.x) > gate.gap * 0.5:
			want = r < t.r_neutral + 4.0 and v.y > -180.0   # stay slim, let the funnel slide us in
		if dist < 300.0 and gate.throat > 0.0 and fits:
			want = v.y > -260.0 and r * 2.0 < gate.gap * 0.8   # build momentum but stay slim
	for g in sim.level.gates:   # inside a throat we just passed into
		if c.y < g.y + 10.0 and c.y > g.y - g.throat - 10.0:
			want = r * 2.0 < g.gap * 0.78 and v.y > -120.0
	var bar = _next_bar(sim, c)
	var bar_block := false
	if bar != null:
		var d: float = c.y - bar.y
		var under: bool = c.x > bar.x0 - r - 30.0 and c.x < bar.x1 + r + 30.0
		if under and d < 340.0:
			bar_block = true
			want = v.y > 30.0          # hover just below the bar
			aim_x = bar.x0 - 90.0 if (bar.x0 - t.r_neutral > 60.0) else bar.x1 + 90.0
	var dx := aim_x - c.x
	for w in sim.winds:
		if (w.rect as Rect2).has_point(c) and absf(dx) > 40.0:
			if signf(w.accel) == signf(dx):
				if not bar_block or (bar != null and c.y - bar.y > 200.0):
					want = true            # sail with it
				elif r < t.r_neutral + 10.0:
					want = true
			elif r > t.r_neutral - 6.0 and v.y < 40.0:
				want = false               # shrink to resist an adverse wind
	if sim.stall_frames > 90 and _drop == 0 and c.y < sim.best_y + 60.0:
		_drop = 45
	if _drop > 0:
		_drop -= 1
		want = false
	if sim.target_r > t.r_pop - 3.0:
		want = false
	if rng.randf() < lerpf(0.18, 0.01, skill):
		want = not want
	_queue.append(want)
	if _queue.size() > _delay:
		return _queue.pop_front()
	return false

func _next_gate(sim: BalloonSim, c: Vector2):
	var best = null
	for g in sim.level.gates:
		if g.y < c.y - 5.0 and (best == null or g.y > best.y):
			best = g
	return best

func _next_bar(sim: BalloonSim, c: Vector2):
	var best = null
	for b in sim.level.bars:
		if b.y < c.y - 5.0 and (best == null or b.y > best.y):
			best = b
	return best
