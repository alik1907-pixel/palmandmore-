# RESEARCH.md — Kaynaklı pazar ve politika bulguları

Kural: her bulgu kaynaklı. Doğrulanamayan "DOĞRULANMADI" olarak işaretlidir. Araştırma tarihi: 2026-11-26.

## 1. Tutma (retention) kıyasları
- **GameAnalytics 2026 (2025 verisi):** medyan D1 ≈ %22, D7 ≈ %4, D30 ≈ %0,7. En iyi %10: D1 ≈ %40, D7 ≈ %12. Örneklem bağımsız/erken aşama stüdyolara kayık. — [Mixpanel özeti](https://mixpanel.com/blog/mobile-gaming-benchmarks-2026/), [GameAnalytics raporu özeti](https://gamedevreports.substack.com/p/gameanalytics-mobile-and-pc-game)
- **Adjust Gaming App Insights 2026:** tüm türlerde ortalama D1 %27 (2025); hiper/hibrit-gündelik en üstte; iyi oyunlar düzenli olarak %40–50 D1. — [Adjust](https://www.adjust.com/blog/gaming-app-insights-2026/)
- **Sensor Tower State of Gaming 2026:** hibrit-gündelik 2025'in gelir artışı en yüksek kategorisi; D7'de gündelik oyunların üstünde. — [Global Games Forum özeti](https://www.globalgamesforum.com/news/state-of-gaming-heres-what-the-mobile-data-actually-says)
- **Sonuç → KPI hedefi:** brief'teki D1 ≥ %40, D7 ≥ %15 hedefleri pazarın **en iyi %10'u** seviyesinde. Gerçekçi ama zor; ara kapı olarak D1 ≥ %35 / D7 ≥ %10 kullanılabilir (KPI.md).

## 2. Yayıncı test eşikleri (ölçekleme kapısı)
- **Homa (hibrit-gündelik):** CPI < 1,0 $, CPTD3 (3 gün toplam oynama) 5000 sn, oyun tamamlama %20. Hiper-gündelik için CPI < 0,4 $ ve D1 > %35. — [Homa destek](https://support.homagames.com/knowledge/how-to-read-the-results-of-a-test)
- Hibrit-gündelik CPI aralıkları kaynaklar arasında çok çelişkili (Tier-1'de 2,5–6 $ diyen de var). Kesin değer için yayıncının kendi testi esas alınmalı. — [Playio CPI](https://blog.playio.co/mobile-game-cpi-benchmarks-2026), [PocketGamer.biz](https://www.pocketgamer.biz/we-dont-talk-about-low-cpis-anymore-as-hybridcasual-raises-player-retention)

## 3. Tür doygunluğu (2026)
- Bulmaca, gündelik gelirin %44'ü (H1 2026). Merge en hızlı büyüyen büyük tür (+%74 harcama). Sort ve Block Puzzle yüzde olarak en hızlı büyüyenler (~%170). Match-3 gelir lideri. → Bunlar **doygun ve yasak listemizde**. — [PocketGamer.biz](https://www.pocketgamer.biz/puzzle-accounts-for-44-of-casual-mobile-earnings-in-h1-2026/), [Gamigion heatmap](https://www.gamigion.com/mobile-puzzle-genres-heatmap-2026/), [Outlook Respawn](https://respawn.outlookindia.com/gaming/gaming-news/top-mobile-puzzle-games-ruling-the-global-grossing-charts-in-2026)
- Mayıs 2026'nın en çok indirilen mobil oyunu "Arrows Puzzle Escape" (Sensor Tower, ikincil kaynak, DOĞRULANMADI). — [Genzopia](https://www.genzopia.com/blog/puzzle-games-statistics-2026)
- Viral kalıp: klip oyunu kendi kendine anlatıyor, izleyen dakikalar içinde oynayabiliyor; fizik kazaları ve komik başarısızlıklar en çok paylaşılan anlar. — [Everything PR](https://everything-pr.com/indie-games-viral-tiktok)

## 4. Özgünlük taraması (konseptler için)
- **YANKI (zaman döngüsü/geçmiş benlik):** Google Play'de "Echo: Time Loop Puzzles" neredeyse birebir aynı (geçmiş benlik + günlük bulmaca + bölüm editörü). Ayrıca The Chronos Principle, Causality, Time Twin (iOS). → **Özgün değil.** — [Play: Echo](https://play.google.com/store/apps/details?id=com.devrocks.echo), [PocketGamer: Chronos Principle](https://www.pocketgamer.com/the-chronos-principle/app-army-assemble-the-chronos-principle-should-you-find-the-time-to-play-this-mi), [Stuff: Causality](https://www.stuff.tv/review/app-of-the-week-causality-review)
- **DALGA (dalga ile nesne itme):** "Water Ripples/Ripples" (taşla dalga yapıp kayığı kıyıya itme) mevcut ama küçük. Girişim (interference) ve risk-ödül odaklı versiyonu yok. → Kısmen özgün. — [TouchArcade: Water Ripples](https://toucharcade.com/games/water-ripples), [itch: Ripple](https://skxptic0.itch.io/ripple)
- **SÜRÜ (kuş sürüsü yönlendirme):** Flocc, Murmuration, Apsis mevcut. → Düşük özgünlük. — [Flocc](https://apps.apple.com/us/app/flocc/id1444795916), [Murmuration](https://braceysmith.itch.io/murmuration), [Apsis](https://www.pocketgamer.com/gathering-sky/create-complex-patterns-by-guiding-a-flock-of-birds-with-your-finger-in-apsis)
- **SONAR (karanlık labirentte yankı):** Echo (341 Games, Play), Dark Echo, Echo Bat. → Özgün değil. — [Play: Echo](https://play.google.com/store/apps/details?id=echo.games), [Dark Echo](https://apps.apple.com/us/app/id951177560)
- **ŞİŞ** ve **KIRILMA**: yapılan aramalarda doğrudan eşleşen bir mobil oyun bulunamadı. DOĞRULANMADI (negatif bulgu; M2 öncesi Play'de anahtar kelime taraması tekrarlanacak).

## 5. Google Play politikaları
- **Kapalı test şartı:** 13 Kasım 2023 sonrası açılan kişisel hesaplar üretime çıkmadan önce **en az 12 test kullanıcısı, kesintisiz 14 gün** kapalı test yapmalı (Aralık 2024'te 20'den 12'ye indi). 14 gün sonunda erişim otomatik açılmaz; başvuru gerekir. — [Play Console Yardım 14151465](https://support.google.com/googleplay/android-developer/answer/14151465), [Android Authority](https://www.androidauthority.com/google-play-app-testing-requirement-3510580)
  - "2026'da etkileşim kontrolleri eklendi" iddiası yalnızca üçüncü taraf bloglarda: DOĞRULANMADI.
- **Hedef API:** 31 Ağustos 2026'dan itibaren yeni uygulamalar ve güncellemeler **API 36 (Android 16)** hedeflemeli. — [Play Console Yardım 11926878](https://support.google.com/googleplay/android-developer/answer/11926878), [developer.android.com target-sdk](https://developer.android.com/google/play/requirements/target-sdk)
- **Android Vitals kötü davranış eşikleri:** kullanıcının algıladığı çökme %1,09, ANR %0,47 (genel); telefon modeli başına %8. Aşılırsa keşfedilebilirlik düşer. — [Android vitals](https://developer.android.com/games/optimize/vitals), [Play Console Yardım 9844486](https://support.google.com/googleplay/android-developer/answer/9844486)
- **AI-Generated Content politikası:** üretken AI özelliği içeren uygulamaları kapsar (içerik üreten chatbot, görsel üretici vb.). Oyunumuz runtime'da AI içerik üretmiyor ve tüm varlıklar kodla üretiliyor → kapsam dışı görünüyor. Oyunlar için ayrı bir AI beyan kuralı bulunamadı: DOĞRULANMADI. — [Play Console Yardım 14094294](https://support.google.com/googleplay/android-developer/answer/14094294)

## 6. Gelir kıyasları (ön araştırma; M5'te derinleşecek)
- ABD Android ödüllü video eCPM: kaynağa göre ~12–30 $ (çelişkili; dönem etiketleri belirsiz). — [Playio eCPM](https://blog.playio.co/mobile-game-ecpm-benchmarks-2026), [Tenjin Ad Mon Gaming 2026](https://tenjin.com/tr/blog/ad-mon-gaming-2026/)
- Hibrit-gündelik ARPDAU (reklam + IAP): 0,15–0,50 $ (tek kaynak, DOĞRULANMADI); yalnızca reklamla ~0,03 $. — [Playio ARPDAU](https://blog.playio.co/arpdau-benchmarks-mobile-games)
- Android reklam gelirinin ~%32'si ABD'den (Tenjin Q2 2026). — [Tenjin](https://tenjin.com/tr/blog/ad-mon-gaming-2026/)

## 7. Google Play öne çıkarma programları
- 2026 için **Indie Games Fund Africa** (yalnızca Sahra altı Afrika). Türkiye'den başvurulabilecek bir 2026 Indie Games Festival sayfası bulunamadı: DOĞRULANMADI, M7'de tekrar bakılacak. — [Android Developers Blog](https://android-developers.googleblog.com/2026/07/Indie-Games-Fund-Africa.html)
