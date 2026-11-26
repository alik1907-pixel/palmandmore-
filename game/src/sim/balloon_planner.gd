class_name BalloonPlanner
extends RefCounted
## Look-ahead (model-predictive) player: every REPLAN frames it simulates a set of
## input patterns HORIZON frames ahead on cloned sims and commits to the best.
## Used for level validation (skill 1.0 = "is this level solvable?") and autoplay.
## Lower skill = fewer patterns considered, slower reaction, execution noise.

const REPLAN := 6
const HORIZON := 54

# pattern = [hold_frames_first, then_hold?]  → hold for k frames, then the other state
const PATTERNS := [[0, false], [0, true], [4, false], [8, false], [16, false], [28, false],
	[4, true], [10, true], [20, true]]

var skill := 1.0
var rng := RandomNumberGenerator.new()
var _plan: Array = []
var _delay_q: Array = []
var _delay := 0
var _noise := 0.0
var _n_patterns := 9
var _over_margin := 8          # frames of over-inflation safety margin kept
var _spike_margin := 40.0      # px of clearance wanted from spikes

func _init(p_skill: float, seed_v: int) -> void:
	skill = p_skill
	rng.seed = seed_v
	_delay = int(lerpf(12.0, 0.0, skill))
	_noise = lerpf(0.10, 0.0, skill)
	_n_patterns = int(lerpf(3.0, 9.0, skill))
	_over_margin = int(lerpf(45.0, 8.0, skill))
	_spike_margin = lerpf(60.0, 22.0, skill)

func decide(sim: BalloonSim) -> bool:
	if _plan.is_empty():
		_plan = _make_plan(sim)
	var want: bool = _plan.pop_front()
	if rng.randf() < _noise:
		want = not want
	_delay_q.append(want)
	if _delay_q.size() > _delay:
		return _delay_q.pop_front()
	return false

func _pattern_input(pat: Array, i: int) -> bool:
	var k: int = pat[0]
	var first_hold: bool = not pat[1] if k > 0 else pat[1]
	if k == 0:
		return pat[1]
	return first_hold if i < k else not first_hold

func _make_plan(sim: BalloonSim) -> Array:
	var order: Array = range(PATTERNS.size())
	if _n_patterns < PATTERNS.size():
		order.shuffle()   # uses global RNG; seed it for determinism below
	var best_score := -INF
	var best_pat: Array = PATTERNS[0]
	for idx in order.slice(0, _n_patterns):
		var pat: Array = PATTERNS[idx]
		var c := sim.clone()
		var peak_over := 0
		for i in HORIZON:
			c.step(_pattern_input(pat, i))
			peak_over = maxi(peak_over, c.over_frames)
			if c.state != "play":
				break
		var sc := _score(sim, c)
		var limit := sim.t.pop_frames - _over_margin
		if peak_over > limit:
			sc -= (peak_over - limit) * 60.0
		if sc > best_score:
			best_score = sc
			best_pat = pat
	var out: Array = []
	for i in REPLAN:
		out.append(_pattern_input(best_pat, i))
	return out

func _score(start: BalloonSim, c: BalloonSim) -> float:
	if c.state == "popped":
		return -100000.0 + (c.frame - start.frame) * 50.0
	if c.state == "won":
		return 100000.0 - c.frame
	var p := c.center()
	var s: float = start.level.start.y - p.y
	var gate = _next(c.level.gates, p)
	if gate != null:
		var d: float = p.y - gate.y
		var w := clampf(1.0 - d / 700.0, 0.0, 1.0)
		s -= absf(p.x - gate.x) * 1.2 * w
		if d < 160.0 and c.radius() * 2.0 > gate.gap * 0.92:
			s -= (c.radius() * 2.0 - gate.gap) * 1.5
	var bar = _next(c.level.bars, p)
	if bar != null:
		var d2: float = p.y - bar.y
		var r := c.radius()
		if d2 < 360.0 and p.x > bar.x0 - r - 20.0 and p.x < bar.x1 + r + 20.0:
			var esc := minf(absf(p.x - (bar.x0 - r - 20.0)), absf(p.x - (bar.x1 + r + 20.0)))
			if bar.x0 <= LevelBuilder.SIDE_L + 1.0:
				esc = absf(p.x - (bar.x1 + r + 20.0))
			elif bar.x1 >= LevelBuilder.SIDE_R - 1.0:
				esc = absf(p.x - (bar.x0 - r - 20.0))
			s -= esc * 0.4 + maxf(0.0, 170.0 - d2) * 3.0
	s -= c.over_frames * 2.0
	s -= _spike_danger(c) * 3.0
	return s

func _spike_danger(c: BalloonSim) -> float:
	var p := c.center()
	var r := c.radius()
	var danger := 0.0
	for sp in c.spikes:
		var d := p.distance_to(Geometry2D.get_closest_point_to_segment(p, sp[0], sp[1])) - r
		if d < _spike_margin:
			danger += _spike_margin - d
	return danger

func _next(list: Array, p: Vector2):
	var best = null
	for g in list:
		if g.y < p.y - 5.0 and (best == null or g.y > best.y):
			best = g
	return best
