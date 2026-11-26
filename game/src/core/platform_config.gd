class_name PlatformConfig
extends RefCounted
## Reads data/platform.json (ad unit ids, product ids, urls).

var admob_app_id := ""
var rewarded_unit := ""
var interstitial_unit := ""
var test_ads := true
var products: PackedStringArray = []
var store_url := ""
var privacy_url := ""
var firebase := {"app_id": "", "api_key": "", "project_id": "", "sender_id": ""}

func firebase_enabled() -> bool:
	return String(firebase.app_id) != "" and String(firebase.api_key) != "" and String(firebase.project_id) != ""

static func load_config() -> PlatformConfig:
	var c := PlatformConfig.new()
	var f := FileAccess.open("res://data/platform.json", FileAccess.READ)
	if f == null:
		return c
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		c.admob_app_id = d.get("admob_app_id", "")
		c.rewarded_unit = d.get("rewarded_unit", "")
		c.interstitial_unit = d.get("interstitial_unit", "")
		c.test_ads = bool(d.get("test_ads", true))
		c.products = PackedStringArray(d.get("products", []))
		c.store_url = d.get("store_url", "")
		c.privacy_url = d.get("privacy_url", "")
		var fb = d.get("firebase", {})
		if fb is Dictionary:
			for k in c.firebase:
				c.firebase[k] = String(fb.get(k, ""))
	return c
