extends Node
## Autoload "Music": procedural, adaptive soundtrack. Four synchronized 8-second
## stems (pad, bass, arpeggio, percussion) are synthesized on a worker thread at
## startup, then layered by game intensity. No audio files, no licensing.

const RATE := 22050
const BPM := 120.0
const BARS := 4
const STEMS := ["pad", "bass", "arp", "perc"]
# A minor → F → C → G (one chord per bar), MIDI notes
const CHORDS := [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]

var _players := {}
var _target := {"pad": -6.0, "bass": -80.0, "arp": -80.0, "perc": -80.0}
var _ready_stems := false
var enabled := true
var _task := -1

func _ready() -> void:
	for s in STEMS:
		var p := AudioStreamPlayer.new()
		p.volume_db = -80.0
		add_child(p)
		_players[s] = p
	_task = WorkerThreadPool.add_task(_build)

func _exit_tree() -> void:
	# never let the synth worker outlive this node (quit during startup)
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
	for p in _players.values():
		p.stop()
		p.stream = null

func _build() -> void:
	var streams := {}
	for s in STEMS:
		streams[s] = _render(s)
	call_deferred("_start", streams)

func _start(streams: Dictionary) -> void:
	if not is_inside_tree():
		return
	for s in STEMS:
		_players[s].stream = streams[s]
	for s in STEMS:
		_players[s].play()     # same frame → stems stay in sync (equal lengths)
	_ready_stems = true

## intensity: 0 menu, 0.3 calm play, 1 tense. size01: balloon size; wind: in wind zone.
func set_mood(intensity: float, size01: float, wind: bool) -> void:
	_target.pad = -8.0
	_target.bass = -10.0 if intensity > 0.2 else -80.0
	_target.arp = lerpf(-30.0, -12.0, size01) if intensity > 0.2 else -80.0
	_target.perc = -12.0 if (wind or intensity > 0.75) else -80.0

func _process(dt: float) -> void:
	if not _ready_stems:
		return
	for s in STEMS:
		var goal: float = _target[s] if enabled else -80.0
		var p: AudioStreamPlayer = _players[s]
		p.volume_db = move_toward(p.volume_db, goal, dt * 30.0)

static func _hz(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)

func _render(stem: String) -> AudioStreamWAV:
	var beat := 60.0 / BPM
	var total := int(BARS * 4 * beat * RATE)
	var buf := PackedFloat32Array()
	buf.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in total:
		var t := float(i) / RATE
		var bar := int(t / (4.0 * beat)) % BARS
		var chord: Array = CHORDS[bar]
		var tb := fmod(t, beat)                 # time since beat
		var t16 := fmod(t, beat / 4.0)          # time since 16th
		var v := 0.0
		match stem:
			"pad":
				var tbar := fmod(t, 4.0 * beat)
				var env := minf(tbar / 0.6, 1.0) * (1.0 - 0.3 * tbar / (4.0 * beat))
				for n in chord:
					var f := _hz(n)
					v += (sin(TAU * f * t) + 0.5 * sin(TAU * f * 1.003 * t) + 0.25 * sin(TAU * f * 2.0 * t)) * 0.09
				v *= env
			"bass":
				var f := _hz(chord[0] - 12)
				v = (sin(TAU * f * t) + 0.35 * sin(TAU * 2.0 * f * t)) * exp(-tb * 5.0) * 0.45
			"arp":
				var step := int(t / (beat / 4.0)) % 4
				var note: int = chord[[0, 1, 2, 1][step]] + 12
				var ph := fmod(_hz(note) * t, 1.0)
				var tri := 4.0 * absf(ph - 0.5) - 1.0
				v = tri * exp(-t16 * 14.0) * 0.22
			"perc":
				var beat_i := int(t / beat) % 4
				if beat_i % 2 == 0:
					v += sin(TAU * (60.0 + 90.0 * exp(-tb * 30.0)) * tb) * exp(-tb * 9.0) * 0.6
				var off := fmod(t + beat / 2.0, beat)
				v += rng.randf_range(-1.0, 1.0) * exp(-off * 60.0) * 0.12
		buf[i] = v
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	for i in total:
		bytes.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.data = bytes
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_end = total
	return w
