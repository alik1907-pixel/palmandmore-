class_name I18n
extends RefCounted
## UI strings for all launch languages, loaded from data/i18n.json
## ({"_langs": [...], "strings": {key: {lang: text}}}). Gameplay itself is wordless.
## Non-Latin glyphs (Devanagari, CJK, Thai, Hangul) come from the Android system font fallback.
## Unsupported system languages fall back to English.

const PATH := "res://data/i18n.json"
const FALLBACK := "en"

static var lang := ""
static var _strings := {}
static var _langs: PackedStringArray = []

static func _ensure() -> void:
	if not _strings.is_empty():
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if d is Dictionary:
		_strings = d.get("strings", {})
		_langs = PackedStringArray(d.get("_langs", [FALLBACK]))
	if _langs.is_empty():
		_langs = PackedStringArray([FALLBACK])

static func langs() -> PackedStringArray:
	_ensure()
	return _langs

## chosen: the player's saved choice ("" = follow the system language).
static func detect(chosen: String) -> void:
	_ensure()
	if chosen in _langs:
		lang = chosen
		return
	var sys := OS.get_locale_language()
	lang = sys if sys in _langs else FALLBACK

static func set_lang(code: String) -> void:
	_ensure()
	lang = code if code in _langs else FALLBACK

static func t(key: String) -> String:
	_ensure()
	if lang == "":
		lang = FALLBACK
	var row: Dictionary = _strings.get(key, {})
	return String(row.get(lang, row.get(FALLBACK, key)))

static func level_name(n: int) -> String:
	return t("level_%d" % n)

static func lang_name(code: String) -> String:
	_ensure()
	var row: Dictionary = _strings.get("lang_name", {})
	return String(row.get(code, code))

static func next_lang() -> String:
	_ensure()
	var i := _langs.find(lang)
	lang = _langs[(i + 1) % _langs.size()]
	return lang
