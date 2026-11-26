extends Node
## Autoload "Platform": consent → ads, purchases, share, review.
## Uses the native SisPlatform plugin when present (Gradle Android builds);
## otherwise a mock: in debug builds rewarded ads "succeed" so flows are testable,
## in release builds ads are simply unavailable (never a broken button).

signal rewarded_done(placement: String, success: bool)
signal purchase_done(product: String, success: bool)
signal prices_ready

const INTERSTITIAL_MIN_LEVEL := 10      # no interstitials until the player passed level 10
const INTERSTITIAL_MIN_SECONDS := 180.0
const INTERSTITIAL_MIN_LEVELS := 2

var cfg: PlatformConfig
var native: Object = null
var ads_allowed := false
var prices := {}
var _pending_placement := ""
var _earned := false
var _last_interstitial := 0.0

func _ready() -> void:
	cfg = PlatformConfig.load_config()
	_last_interstitial = Time.get_ticks_msec() / 1000.0
	if Engine.has_singleton("SisPlatform"):
		native = Engine.get_singleton("SisPlatform")
		native.connect("consent_finished", _on_consent)
		native.connect("rewarded_earned", _on_rewarded_earned)
		native.connect("ad_closed", _on_ad_closed)
		native.connect("ad_failed", _on_ad_failed)
		native.connect("billing_ready", _on_billing_ready)
		native.connect("purchase_result", _on_purchase_result)
		native.connect("owned_products", _on_owned)
		native.requestConsent()
		native.billingConnect(",".join(cfg.products))

func has_native() -> bool:
	return native != null

# ------------------------------------------------------------------ consent / ads
func _on_consent(can_request: bool) -> void:
	ads_allowed = can_request
	Profile.data.consent_done = true
	Profile.save()
	Analytics.log_event("consent", {"can_request_ads": can_request})
	if can_request:
		native.initAds(cfg.rewarded_unit, cfg.interstitial_unit)

func privacy_options_available() -> bool:
	return native != null and native.privacyOptionsRequired()

func show_privacy_options() -> void:
	if native != null:
		native.showPrivacyOptions()

func rewarded_available() -> bool:
	if native != null:
		return ads_allowed and native.isRewardedReady()
	return OS.is_debug_build()

func show_rewarded(placement: String) -> void:
	Analytics.log_event("ad_offer_accept", {"placement": placement})
	_pending_placement = placement
	_earned = false
	if native != null and rewarded_available():
		native.showRewarded(placement)
		return
	if native == null and OS.is_debug_build():
		await get_tree().create_timer(0.6).timeout
		_finish_rewarded(true)
		return
	_finish_rewarded(false)

func _on_rewarded_earned(placement: String) -> void:
	_earned = true

func _on_ad_closed(kind: String) -> void:
	if kind == "rewarded":
		_finish_rewarded(_earned)
	else:
		_last_interstitial = Time.get_ticks_msec() / 1000.0

func _on_ad_failed(kind: String, msg: String) -> void:
	if kind == "rewarded" and _pending_placement != "":
		_finish_rewarded(false)

func _finish_rewarded(ok: bool) -> void:
	var p := _pending_placement
	_pending_placement = ""
	if p == "":
		return
	Analytics.log_event("ad_reward" if ok else "ad_reward_fail", {"placement": p})
	rewarded_done.emit(p, ok)

## Called only between levels. Applies the pacing policy (GDD §9 / brief M5).
func maybe_interstitial(levels_completed: int) -> void:
	if Profile.data.ads_removed or native == null or not ads_allowed:
		return
	Profile.data.levels_since_interstitial = int(Profile.data.levels_since_interstitial) + 1
	var now := Time.get_ticks_msec() / 1000.0
	if levels_completed <= INTERSTITIAL_MIN_LEVEL:
		return
	if now - _last_interstitial < INTERSTITIAL_MIN_SECONDS:
		return
	if int(Profile.data.levels_since_interstitial) < INTERSTITIAL_MIN_LEVELS:
		return
	if native.isInterstitialReady():
		Profile.data.levels_since_interstitial = 0
		_last_interstitial = now
		Analytics.log_event("ad_interstitial", {})
		native.showInterstitial()

# ------------------------------------------------------------------ purchases
func _on_billing_ready(price_list: String) -> void:
	for pair in price_list.split(";", false):
		var kv := pair.split("=")
		if kv.size() == 2:
			prices[kv[0]] = kv[1]
	prices_ready.emit()

func price_of(product: String) -> String:
	return prices.get(product, "")

func can_buy(product: String) -> bool:
	return native != null and prices.has(product)

func buy(product: String) -> void:
	Analytics.log_event("iap_click", {"product": product})
	if native != null:
		native.purchase(product)
	elif OS.is_debug_build():
		_on_purchase_result(product, true, "mock")
	else:
		purchase_done.emit(product, false)

func restore() -> void:
	if native != null:
		native.restorePurchases()

func _on_purchase_result(product: String, ok: bool, msg: String) -> void:
	if ok:
		_grant(product)
		Analytics.log_event("purchase", {"product": product})
	purchase_done.emit(product, ok)

func _on_owned(csv: String) -> void:
	for p in csv.split(",", false):
		_grant(p)

func _grant(product: String) -> void:
	match product:
		"remove_ads":
			Profile.set_ads_removed()
		"theme_pack":
			Profile.grant_all_styles()
		"cosmetic_pack":
			Profile.grant_skin("rainbow")

# ------------------------------------------------------------------ share / review
func share(text: String) -> void:
	Analytics.log_event("share", {})
	if native != null:
		native.shareText(text)
	else:
		DisplayServer.clipboard_set(text)

func request_review() -> void:
	if native != null:
		native.requestReview()
