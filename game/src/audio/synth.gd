class_name Synth
extends RefCounted
## All game sounds are synthesized here at startup (no audio files, no licenses).
## Deterministic: noise uses a fixed seed so every build sounds identical.

const RATE := 44100

static func _wav(buf: PackedFloat32Array, loop := false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		bytes.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = bytes
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = buf.size()
	return w

static func _buf(sec: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(sec * RATE))
	return b

static func pop() -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new(); rng.seed = 11
	var b := _buf(0.45)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var n := rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * 0.35
		var crack := n * exp(-t * 90.0) * 0.9
		var body := lp * exp(-t * 14.0) * 0.9
		var thump := sin(TAU * (95.0 - 40.0 * t) * t) * exp(-t * 9.0) * 0.8
		b[i] = crack + body + thump
	return _wav(b)

static func squeak(base := 700.0) -> AudioStreamWAV:
	var b := _buf(0.11)
	var ph := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var f := base + 900.0 * t / 0.11 + sin(TAU * 38.0 * t) * 60.0
		ph += TAU * f / RATE
		var env := sin(PI * t / 0.11)
		b[i] = (sin(ph) * 0.7 + sin(ph * 2.0) * 0.2) * env * 0.6
	return _wav(b)

static func squeeze() -> AudioStreamWAV:
	var b := _buf(0.32)
	var ph := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var f := 170.0 + 60.0 * sin(TAU * 3.0 * t)
		ph += f / RATE
		var saw := 2.0 * (ph - floorf(ph)) - 1.0
		var am := 0.6 + 0.4 * sin(TAU * 26.0 * t)
		b[i] = saw * am * sin(PI * t / 0.32) * 0.45
	return _wav(b)

static func hiss_loop() -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new(); rng.seed = 23
	var b := _buf(1.0)
	var lp := 0.0
	var hp := 0.0
	for i in b.size():
		var n := rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * 0.25
		hp = lp - hp * 0.2
		b[i] = hp * 0.35
	_crossfade_loop(b)
	return _wav(b, true)

static func deflate_loop() -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new(); rng.seed = 37
	var b := _buf(1.0)
	var lp := 0.0
	var ph := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += (rng.randf_range(-1.0, 1.0) - lp) * 0.12
		ph += (110.0 + 8.0 * sin(TAU * 5.0 * t)) / RATE
		var pulse := 1.0 if fmod(ph, 1.0) < 0.3 else -0.4
		b[i] = lp * 0.35 + pulse * 0.08
	_crossfade_loop(b)
	return _wav(b, true)

static func wind_loop() -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new(); rng.seed = 51
	var b := _buf(2.0)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var cut := 0.02 + 0.03 * (0.5 + 0.5 * sin(TAU * 0.5 * t))
		lp += (rng.randf_range(-1.0, 1.0) - lp) * cut
		b[i] = lp * 1.6
	_crossfade_loop(b)
	return _wav(b, true)

static func tick() -> AudioStreamWAV:
	var b := _buf(0.035)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = sin(TAU * 1800.0 * t) * exp(-t * 120.0) * 0.6
	return _wav(b)

static func whoosh() -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new(); rng.seed = 77
	var b := _buf(0.4)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += (rng.randf_range(-1.0, 1.0) - lp) * (0.05 + 0.4 * t / 0.4)
		b[i] = lp * sin(PI * t / 0.4) * 1.2
	return _wav(b)

static func win() -> AudioStreamWAV:
	var notes := [523.25, 659.25, 783.99, 1046.5]
	var b := _buf(0.9)
	for i in b.size():
		var t := float(i) / RATE
		var s := 0.0
		for k in notes.size():
			var st := k * 0.11
			if t >= st:
				var u := t - st
				s += (sin(TAU * notes[k] * u) + 0.3 * sin(TAU * notes[k] * 2.0 * u)) * exp(-u * 5.0) * 0.28
		b[i] = s
	return _wav(b)

static func _crossfade_loop(b: PackedFloat32Array) -> void:
	var n := int(0.05 * RATE)
	var size := b.size()
	for i in n:
		var a := float(i) / n
		b[i] = b[i] * a + b[size - n + i] * (1.0 - a)
