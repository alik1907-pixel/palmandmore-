class_name Sfx
extends Node
## Plays synthesized sounds. One-shots use a small player pool; inflate/deflate/wind
## are continuous loops whose volume and pitch follow the balloon each frame.

var streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _inflate: AudioStreamPlayer
var _deflate: AudioStreamPlayer
var _wind: AudioStreamPlayer
var muted := false

func _ready() -> void:
	streams = {"pop": Synth.pop(), "squeak": Synth.squeak(), "squeeze": Synth.squeeze(),
		"tick": Synth.tick(), "whoosh": Synth.whoosh(), "win": Synth.win()}
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	_inflate = _loop(Synth.hiss_loop())
	_deflate = _loop(Synth.deflate_loop())
	_wind = _loop(Synth.wind_loop())

func _loop(s: AudioStream) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = s
	p.volume_db = -80.0
	add_child(p)
	p.play()
	return p

func play(name: String, pitch := 1.0, vol_db := 0.0) -> void:
	if muted or not streams.has(name):
		return
	for p in _pool:
		if not p.playing:
			p.stream = streams[name]
			p.pitch_scale = pitch
			p.volume_db = vol_db
			p.play()
			return

## Called every frame. inflating: -1 shrinking, 0 idle, 1 growing; size01: 0..1; wind01: 0..1
func set_loops(inflating: int, size01: float, wind01: float) -> void:
	var on := not muted
	_inflate.volume_db = lerpf(_inflate.volume_db, -10.0 if (on and inflating > 0) else -80.0, 0.3)
	_inflate.pitch_scale = 0.8 + size01 * 0.9
	_deflate.volume_db = lerpf(_deflate.volume_db, -12.0 if (on and inflating < 0) else -80.0, 0.3)
	_deflate.pitch_scale = 1.3 - size01 * 0.5
	_wind.volume_db = lerpf(_wind.volume_db, lerpf(-40.0, -8.0, wind01) if on else -80.0, 0.05)

func silence() -> void:
	set_loops(0, 0.0, 0.0)

func _exit_tree() -> void:
	# release playbacks so the audio server holds no stream references at quit
	for c in get_children():
		if c is AudioStreamPlayer:
			c.stop()
			c.stream = null
