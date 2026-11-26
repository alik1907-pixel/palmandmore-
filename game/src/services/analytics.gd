extends Node
## Autoload "Analytics": one call site for every product event (docs/KPI.md schema).
## Events go to a local rolling log (QA / closed test export) and to the native
## bridge (Logcat today; a real analytics backend can be attached there later).

const LOG := "user://events.jsonl"
const MAX_LINES := 3000

var _session := ""
var _buffer: Array[String] = []

func _ready() -> void:
	_session = "%d-%d" % [Time.get_unix_time_from_system(), randi() % 100000]
	log_event("session_start", {"sessions": Profile.data.sessions, "day": Profile.today() - int(Profile.data.first_day)})

func log_event(name: String, params := {}) -> void:
	var e := {"t": Time.get_unix_time_from_system(), "s": _session, "e": name}
	e.merge(params)
	var line := JSON.stringify(e)
	_buffer.append(line)
	if Engine.has_singleton("SisPlatform"):
		Engine.get_singleton("SisPlatform").logEvent(name, JSON.stringify(params))
	if _buffer.size() >= 10 or name in ["level_complete", "level_fail", "purchase", "session_start"]:
		flush()

func flush() -> void:
	if _buffer.is_empty():
		return
	var lines: PackedStringArray = []
	if FileAccess.file_exists(LOG):
		var r := FileAccess.open(LOG, FileAccess.READ)
		if r != null:
			lines = r.get_as_text().split("\n", false)
	lines.append_array(_buffer)
	_buffer.clear()
	if lines.size() > MAX_LINES:
		lines = lines.slice(lines.size() - MAX_LINES)
	var w := FileAccess.open(LOG, FileAccess.WRITE)
	if w != null:
		w.store_string("\n".join(lines) + "\n")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		flush()
