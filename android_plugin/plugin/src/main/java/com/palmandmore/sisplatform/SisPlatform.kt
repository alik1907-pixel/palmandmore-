package com.palmandmore.sisplatform

import android.content.Intent
import android.os.Bundle
import org.json.JSONObject
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.analytics.FirebaseAnalytics
import android.util.Log
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.play.core.review.ReviewManagerFactory
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Platform bridge for ŞİŞ: consent (UMP), ads (AdMob), purchases (Play Billing),
 * share and in-app review. All results come back to Godot as signals.
 * Every entry point is safe to call repeatedly and never throws into Godot.
 */
class SisPlatform(godot: Godot) : GodotPlugin(godot) {

    private val tag = "SisPlatform"
    private var consentInfo: ConsentInformation? = null
    private val adsInitialized = AtomicBoolean(false)
    private var rewardedId = ""
    private var interstitialId = ""
    private var rewarded: RewardedAd? = null
    private var interstitial: InterstitialAd? = null
    private var rewardedLoading = false
    private var interstitialLoading = false

    private var billing: BillingClient? = null
    private val productDetails = HashMap<String, ProductDetails>()
    private var productIds: List<String> = emptyList()

    private var analytics: FirebaseAnalytics? = null

    override fun getPluginName() = "SisPlatform"

    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo("consent_finished", java.lang.Boolean::class.java),
        SignalInfo("ad_loaded", String::class.java),
        SignalInfo("ad_failed", String::class.java, String::class.java),
        SignalInfo("ad_closed", String::class.java),
        SignalInfo("rewarded_earned", String::class.java),
        SignalInfo("billing_ready", String::class.java),
        SignalInfo("purchase_result", String::class.java, java.lang.Boolean::class.java, String::class.java),
        SignalInfo("owned_products", String::class.java),
    )

    private fun ui(block: () -> Unit) {
        val a = activity ?: return
        a.runOnUiThread {
            try { block() } catch (e: Throwable) { Log.e(tag, "ui block failed", e) }
        }
    }

    // ------------------------------------------------------------------ consent
    @UsedByGodot
    fun requestConsent() = ui {
        val a = activity ?: return@ui
        val info = UserMessagingPlatform.getConsentInformation(a)
        consentInfo = info
        val params = ConsentRequestParameters.Builder().build()
        info.requestConsentInfoUpdate(a, params, {
            UserMessagingPlatform.loadAndShowConsentFormIfRequired(a) { err ->
                if (err != null) Log.w(tag, "consent form: ${err.message}")
                emitSignal("consent_finished", info.canRequestAds())
            }
        }, { err ->
            Log.w(tag, "consent update failed: ${err.message}")
            emitSignal("consent_finished", info.canRequestAds())
        })
    }

    @UsedByGodot
    fun canRequestAds(): Boolean = consentInfo?.canRequestAds() ?: false

    @UsedByGodot
    fun privacyOptionsRequired(): Boolean =
        consentInfo?.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED

    @UsedByGodot
    fun showPrivacyOptions() = ui {
        val a = activity ?: return@ui
        UserMessagingPlatform.showPrivacyOptionsForm(a) { err ->
            if (err != null) Log.w(tag, "privacy options: ${err.message}")
        }
    }

    // ------------------------------------------------------------------ ads
    @UsedByGodot
    fun initAds(rewardedUnit: String, interstitialUnit: String) = ui {
        rewardedId = rewardedUnit
        interstitialId = interstitialUnit
        val a = activity ?: return@ui
        if (adsInitialized.compareAndSet(false, true)) {
            Thread {
                MobileAds.initialize(a) {
                    ui { loadRewarded(); loadInterstitial() }
                }
            }.start()
        } else {
            loadRewarded(); loadInterstitial()
        }
    }

    @UsedByGodot
    fun loadRewarded() = ui {
        val a = activity ?: return@ui
        if (rewardedId.isEmpty() || rewarded != null || rewardedLoading) return@ui
        rewardedLoading = true
        RewardedAd.load(a, rewardedId, AdRequest.Builder().build(), object : RewardedAdLoadCallback() {
            override fun onAdLoaded(ad: RewardedAd) {
                rewardedLoading = false
                rewarded = ad
                emitSignal("ad_loaded", "rewarded")
            }
            override fun onAdFailedToLoad(error: LoadAdError) {
                rewardedLoading = false
                rewarded = null
                emitSignal("ad_failed", "rewarded", error.message)
            }
        })
    }

    @UsedByGodot
    fun isRewardedReady(): Boolean = rewarded != null

    @UsedByGodot
    fun showRewarded(placement: String) = ui {
        val a = activity ?: return@ui
        val ad = rewarded
        if (ad == null) {
            emitSignal("ad_failed", "rewarded", "not_ready")
            loadRewarded()
            return@ui
        }
        rewarded = null
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                emitSignal("ad_closed", "rewarded")
                loadRewarded()
            }
            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                emitSignal("ad_failed", "rewarded", error.message)
                loadRewarded()
            }
        }
        ad.show(a) { _ -> emitSignal("rewarded_earned", placement) }
    }

    @UsedByGodot
    fun loadInterstitial() = ui {
        val a = activity ?: return@ui
        if (interstitialId.isEmpty() || interstitial != null || interstitialLoading) return@ui
        interstitialLoading = true
        InterstitialAd.load(a, interstitialId, AdRequest.Builder().build(), object : InterstitialAdLoadCallback() {
            override fun onAdLoaded(ad: InterstitialAd) {
                interstitialLoading = false
                interstitial = ad
                emitSignal("ad_loaded", "interstitial")
            }
            override fun onAdFailedToLoad(error: LoadAdError) {
                interstitialLoading = false
                interstitial = null
                emitSignal("ad_failed", "interstitial", error.message)
            }
        })
    }

    @UsedByGodot
    fun isInterstitialReady(): Boolean = interstitial != null

    @UsedByGodot
    fun showInterstitial() = ui {
        val a = activity ?: return@ui
        val ad = interstitial ?: run { loadInterstitial(); return@ui }
        interstitial = null
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                emitSignal("ad_closed", "interstitial")
                loadInterstitial()
            }
            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                emitSignal("ad_failed", "interstitial", error.message)
                loadInterstitial()
            }
        }
        ad.show(a)
    }

    // ------------------------------------------------------------------ billing
    private val purchasesListener = PurchasesUpdatedListener { result, purchases ->
        if (result.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            purchases.forEach { handlePurchase(it, true) }
        } else if (result.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
            emitSignal("purchase_result", "", false, "canceled")
        } else {
            emitSignal("purchase_result", "", false, "error_${result.responseCode}")
        }
    }

    @UsedByGodot
    fun billingConnect(productIdsCsv: String) = ui {
        val a = activity ?: return@ui
        productIds = productIdsCsv.split(",").map { it.trim() }.filter { it.isNotEmpty() }
        val client = billing ?: BillingClient.newBuilder(a)
            .setListener(purchasesListener)
            .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
            .build().also { billing = it }
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    queryProducts()
                    restorePurchases()
                } else {
                    Log.w(tag, "billing setup: ${result.debugMessage}")
                }
            }
            override fun onBillingServiceDisconnected() {
                Log.w(tag, "billing disconnected")
            }
        })
    }

    private fun queryProducts() {
        val client = billing ?: return
        if (productIds.isEmpty()) return
        val products = productIds.map {
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(it)
                .setProductType(BillingClient.ProductType.INAPP)
                .build()
        }
        val params = QueryProductDetailsParams.newBuilder().setProductList(products).build()
        client.queryProductDetailsAsync(params) { result, details ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                details.productDetailsList.forEach { productDetails[it.productId] = it }
                val prices = productDetails.values.joinToString(";") {
                    "${it.productId}=${it.oneTimePurchaseOfferDetails?.formattedPrice ?: ""}"
                }
                emitSignal("billing_ready", prices)
            }
        }
    }

    @UsedByGodot
    fun purchase(productId: String) = ui {
        val a = activity ?: return@ui
        val client = billing
        val details = productDetails[productId]
        if (client == null || details == null) {
            emitSignal("purchase_result", productId, false, "unavailable")
            return@ui
        }
        val params = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(listOf(
                BillingFlowParams.ProductDetailsParams.newBuilder().setProductDetails(details).build()
            )).build()
        client.launchBillingFlow(a, params)
    }

    @UsedByGodot
    fun restorePurchases() {
        val client = billing ?: return
        val params = QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP).build()
        client.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                val owned = purchases.filter { it.purchaseState == Purchase.PurchaseState.PURCHASED }
                owned.forEach { handlePurchase(it, false) }
                emitSignal("owned_products", owned.flatMap { it.products }.joinToString(","))
            }
        }
    }

    private fun handlePurchase(p: Purchase, notify: Boolean) {
        if (p.purchaseState != Purchase.PurchaseState.PURCHASED) {
            if (notify) emitSignal("purchase_result", p.products.firstOrNull() ?: "", false, "pending")
            return
        }
        if (!p.isAcknowledged) {
            val ack = AcknowledgePurchaseParams.newBuilder().setPurchaseToken(p.purchaseToken).build()
            billing?.acknowledgePurchase(ack) { r ->
                if (r.responseCode != BillingClient.BillingResponseCode.OK) Log.w(tag, "ack failed: ${r.debugMessage}")
            }
        }
        if (notify) p.products.forEach { emitSignal("purchase_result", it, true, "ok") }
    }

    // ------------------------------------------------------------------ misc
    @UsedByGodot
    fun shareText(text: String) = ui {
        val a = activity ?: return@ui
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        a.startActivity(Intent.createChooser(send, null))
    }

    @UsedByGodot
    fun requestReview() = ui {
        val a = activity ?: return@ui
        val manager = ReviewManagerFactory.create(a)
        manager.requestReviewFlow().addOnCompleteListener { task ->
            if (task.isSuccessful) manager.launchReviewFlow(a, task.result)
        }
    }

    // ------------------------------------------------------------------ analytics
    /**
     * Initializes Firebase from explicit ids (no google-services.json / Gradle plugin needed).
     * Collection starts DISABLED; call setAnalyticsEnabled(true) after the consent flow.
     */
    @UsedByGodot
    fun initFirebase(appId: String, apiKey: String, projectId: String, senderId: String): Boolean {
        val a = activity ?: return false
        if (appId.isEmpty() || apiKey.isEmpty() || projectId.isEmpty()) return false
        return try {
            val app = FirebaseApp.getApps(a).firstOrNull() ?: FirebaseApp.initializeApp(
                a.applicationContext,
                FirebaseOptions.Builder()
                    .setApplicationId(appId)
                    .setApiKey(apiKey)
                    .setProjectId(projectId)
                    .setGcmSenderId(senderId)
                    .build()
            )
            if (app == null) return false
            analytics = FirebaseAnalytics.getInstance(a.applicationContext).also {
                it.setAnalyticsCollectionEnabled(false)
            }
            true
        } catch (e: Throwable) {
            Log.e(tag, "firebase init failed", e)
            false
        }
    }

    @UsedByGodot
    fun setAnalyticsEnabled(enabled: Boolean) {
        analytics?.setAnalyticsCollectionEnabled(enabled)
    }

    /** Godot sends params as a JSON object; numbers become doubles/longs, the rest strings. */
    @UsedByGodot
    fun logEvent(name: String, json: String) {
        val fa = analytics
        if (fa == null) {
            Log.i(tag, "event $name $json")
            return
        }
        try {
            val b = Bundle()
            val o = JSONObject(if (json.isEmpty()) "{}" else json)
            val keys = o.keys()
            var n = 0
            while (keys.hasNext() && n < 25) {
                val k = keys.next()
                when (val v = o.get(k)) {
                    is Int -> b.putLong(k, v.toLong())
                    is Long -> b.putLong(k, v)
                    is Double -> b.putDouble(k, v)
                    is Boolean -> b.putLong(k, if (v) 1L else 0L)
                    else -> b.putString(k, v.toString().take(100))
                }
                n++
            }
            fa.logEvent(name.take(40), b)
        } catch (e: Throwable) {
            Log.w(tag, "logEvent failed: ${e.message}")
        }
    }
}
