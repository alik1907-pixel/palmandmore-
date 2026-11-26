extends Node
## Autoload "Profile": the player's persistent state. Saved atomically as JSON in user://.
## Only this node writes the save file; everything else reads/changes via methods.

signal changed

const PATH := "user://profile.json"
const VERSION := 1

var data := {}
var persist := true          # tests set false so they never touch the real save

func _ready() -> void:
	load_profile()

func _defaults() -> Dictionary:
	return {
		"version": VERSION,
		"unlocked": 1,
		"stars": {},            # "level" -> 0..3
		"best_time": {},        # "level" -> seconds
		"style": ArtStyle.DEFAULT,
		"skin": "classic",
		"owned_styles": [ArtStyle.DEFAULT],
		"owned_skins": ["classic"],
		"streak": 0,
		"best_streak": 0,
		"last_daily": -1,       # day index of the last completed daily
		"daily_best": {},       # "day" -> seconds
		"ads_removed": false,
		"settings": {"sound": true, "music": true, "haptics": true, "lang": "", "text_scale": 0},
		"first_day": -1,
		"sessions": 0,
		"levels_since_interstitial": 0,
		"consent_done": false,
	}

func load_profile() -> void:
	data = _defaults()
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text()) if f != null else null
		if parsed is Dictionary:
			for k in parsed:
				data[k] = parsed[k]
	data.version = VERSION
	if int(data.first_day) < 0:
		data.first_day = today()
	data.sessions = int(data.sessions) + 1
	save()

func save() -> void:
	if not persist:
		changed.emit()
		return
	var tmp := PATH + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "", false))
	f.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(PATH))
	changed.emit()

static func today() -> int:
	## Local calendar day index (days since 1970-01-01 in local time).
	var now: float = Time.get_unix_time_from_system() + float(Time.get_time_zone_from_system().bias) * 60.0
	return int(floor(now / 86400.0))

# ------------------------------------------------------------- progress
func stars_of(level: int) -> int:
	return int(data.stars.get(str(level), 0))

func total_stars() -> int:
	var t := 0
	for k in data.stars:
		t += int(data.stars[k])
	return t

func record_level(level: int, stars: int, seconds: float) -> Dictionary:
	## Returns what changed: {"new_best": bool, "new_stars": int, "unlocks": Array}
	var key := str(level)
	var before := stars_of(level)
	var res := {"new_best": false, "new_stars": maxi(stars - before, 0), "unlocks": []}
	if stars > before:
		data.stars[key] = stars
	var best := float(data.best_time.get(key, 0.0))
	if seconds < 9000.0 and (best <= 0.0 or seconds < best):     # assisted runs never set records
		data.best_time[key] = snappedf(seconds, 0.01)
		res.new_best = best > 0.0
	data.unlocked = maxi(int(data.unlocked), level + 1)
	res.unlocks = _check_unlocks()
	save()
	return res

func record_daily(seconds: float) -> Dictionary:
	var d := today()
	var res := {"first_today": int(data.last_daily) != d, "streak": int(data.streak), "unlocks": []}
	if res.first_today:
		data.streak = int(data.streak) + 1 if int(data.last_daily) == d - 1 else 1
		data.last_daily = d
		data.best_streak = maxi(int(data.best_streak), int(data.streak))
	var key := str(d)
	var best := float(data.daily_best.get(key, 0.0))
	if best <= 0.0 or seconds < best:
		data.daily_best[key] = snappedf(seconds, 0.01)
	res.streak = int(data.streak)
	res.unlocks = _check_unlocks()
	save()
	return res

func streak_alive() -> int:
	## Streak counts only if the last daily was today or yesterday.
	var d := today()
	return int(data.streak) if int(data.last_daily) >= d - 1 else 0

# ------------------------------------------------------------- cosmetics
func _check_unlocks() -> Array:
	var got: Array = []
	for skin in Skins.ALL:
		var req: Dictionary = Skins.unlock_rule(skin)
		if data.owned_skins.has(skin):
			continue
		if req.get("stars", 999999) <= total_stars() or req.get("streak", 999999) <= int(data.best_streak):
			data.owned_skins.append(skin)
			got.append(skin)
	for st in ArtStyle.IDS:
		if data.owned_styles.has(st):
			continue
		var need: int = ArtStyle.unlock_stars(st)
		if need <= total_stars():
			data.owned_styles.append(st)
			got.append("style:" + st)
	return got

func grant_skin(skin: String) -> void:
	if not data.owned_skins.has(skin):
		data.owned_skins.append(skin)
		save()

func grant_all_styles() -> void:
	for st in ArtStyle.IDS:
		if not data.owned_styles.has(st):
			data.owned_styles.append(st)
	save()

func set_style(st: String) -> void:
	if data.owned_styles.has(st):
		data.style = st
		save()

func set_skin(skin: String) -> void:
	if data.owned_skins.has(skin):
		data.skin = skin
		save()

func setting(key: String) -> bool:
	return bool(data.settings.get(key, true))

func toggle_setting(key: String) -> void:
	data.settings[key] = not setting(key)
	save()

func set_ads_removed() -> void:
	data.ads_removed = true
	save()
