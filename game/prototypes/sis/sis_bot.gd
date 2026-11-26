class_name SisBot
extends RefCounted
## Heuristic player for difficulty measurement. `skill` 0..1 controls reaction
## delay and noise so a population of bots approximates a player population.

var skill := 0.5
var rng := RandomNumberGenerator.new()
var _queue: Array = []   # delayed decisions
var delay := 0
var _drop := 0

func _init(p_skill: float, seed_v: int) -> void:
	skill = p_skill
	rng.seed = seed_v
	delay = int(lerp(14.0, 2.0, skill))

func decide(sim: SisSim) -> bool:
	var c := sim.center()
	var v := sim.velocity()
	var r := sim.radius()
	var next_gate = null
	for g in sim.level.gates:
		if g.y < c.y - 5.0:
			next_gate = g
			break
	var want := v.y > -140.0          # keep rising at ~140 px/s
	if next_gate != null:
		var dist: float = c.y - next_gate.y
		var fits: bool = r * 2.0 < next_gate.gap * 0.92
		if dist < 240.0 and not fits:
			want = false                 # squeeze: deflate, ride momentum
		var dx: float = next_gate.x - c.x
		for w in sim.winds:
			if (w[0] as Rect2).has_point(c) and sign(w[1]) == sign(dx) and abs(dx) > 40.0 and dist > 200.0:
				want = true              # sail with the wind
	if sim.stall_frames > 90 and _drop == 0:
		_drop = 45                       # wedged: let go, sink, retry
	if _drop > 0:
		_drop -= 1
		want = false
	if sim.target_r > SisSim.R_POP - 3.0:
		want = false
	if rng.randf() < lerp(0.18, 0.01, skill):
		want = not want                  # human noise
	_queue.append(want)
	if _queue.size() > delay:
		return _queue.pop_front()
	return false
