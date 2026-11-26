# DECISIONS.md — Kararlar, alternatifler, gerekçeler

## D1 — Motor: Godot 4.7.2 (GDScript) · 2026-11-26
- **Alternatifler:** Unity (reklam mediation SDK ekosistemi daha olgun; ama ikili sahne dosyaları + lisans + büyük APK), Defold (küçük, ama topluluk/eklenti daha az).
- **Gerekçe:** Metin tabanlı sahneler, headless CLI test/export, `--write-movie` ile otomatik video, lisans ücreti yok. Brief ile uyumlu.
- **Risk:** AdMob, Play Billing ve Firebase eklentilerinin 4.7 ile uyumu M5'te doğrulanacak.

## D2 — Renderer: GL Compatibility · 2026-11-26
- Düşük donanımlı Android cihazlarda en geniş uyum. Bulut makinede GPU olmadan (llvmpipe) video kaydı yapılabiliyor.

## D3 — Godot projesi `game/` alt klasöründe · 2026-11-26
- Repo kökü belgeler, medya ve scriptler için. Kökteki boş Expo dosyalarına dokunulmadı.

## D4 — Prototip mimarisi: saf simülasyon + görünüm ayrımı · 2026-11-26
- `*_sim.gd` (RefCounted, deterministik, fizik motoru kullanmaz) + `*_view.gd` (çizim/girdi) + `*_bot.gd` + `tools/*_botsim.gd`.
- Gerekçe: Headless'ta binlerce oyun hızlı simüle edilebiliyor. Replay/determinizm testleri M2'de kolaylaşacak. Godot fizik motoru deterministik değil.

## D5 — Tohum konsept YANKI elendi · 2026-11-26
- Google Play'de "Echo: Time Loop Puzzles" neredeyse aynı (RESEARCH.md §4). Brief'in "daha iyisini bulursan onu öner" maddesi uygulandı.

## D6 — FERRO ile DALGA eşitliği DALGA lehine bozuldu · 2026-11-26
- İkisi de 47 puan. Eşitlik kuralı: daha düşük teknik risk kazanır.

## D7 — Prototip ayar değişiklikleri (bot verisiyle)
- ŞİŞ: Düz tavanlı kapılar balonu sıkıştırıyordu → tam huniye çevrildi. Dikenler sadece rüzgâr bölgesi olan kapılarda (oyuncuya araç verilmeden ceza yok).
- KIRILMA: Panel üst kenardan değil, yalnızca süsün sapından asılı → oyulan bölgeler büyük parçalar hâlinde düşüyor. Çatlak süse çarpınca o yönde duruyor (en fazla bir süs parçası kırılır).
- DALGA: Taş çukur değil kabarma oluşturuyor → fener taştan uzağa itiliyor (sezgisel). Sönüm 0,99 → dalgalar ~2 sn'de yatışıyor.

## D8 — GATE 1: ŞİŞ seçildi · 2026-11-26
- Yapımcı kararı ("1.yi yap"). KIRILMA ve DALGA prototipleri `game/prototypes/` altında arşiv olarak duruyor.

## D9 — Test çerçevesi: GUT yerine GUT tarzı minimal koşucu · 2026-11-26
- GUT indirilemedi (github arşivleri ve godotengine.org proxy'de 403). `tests/test_case.gd` + `tools/run_tests.gd` aynı yapıyı (test_*.gd / test_* metotları) kullanır; ileride GUT'a geçiş kolay.

## D10 — Bölüm doğrulama botu: kural tabanlıdan planlayıcıya (MPC) · 2026-11-26
- Kural tabanlı bot her yeni engel türünde yeni kural istiyordu ve sonuçlar bot hatalarını ölçüyordu. `BalloonPlanner`, simülasyonun kopyasında 9 basma/bırakma desenini 54 kare ileri oynatıp en iyisini seçer.
- Beceri parametreleri: düşünülen desen sayısı, tepki gecikmesi (12→0 kare), hata oranı (%10→0), aşırı şişirme ve diken güvenlik payı. Uzman = çözülebilirlik kanıtı.
- Sınır: bot insan değildir. Gerçek zorluk verisi kapalı testte toplanacak.

## D11 — Fizik ayarları (bot verisiyle) · 2026-11-26
- Dikey hava direnci (son hız ~350 px/sn): eskiden 1. bölüm 2,4 sn'de bitiyordu, şimdi ~8–10 sn.
- Kaldırma kuvveti r_pop'ta doyuyor: aşırı şişirme her bölümde baskın ölüm nedeniydi (%60–90); şimdi ~%0–4.
- Aşırı şişirme patlaması 1–2. bölümlerde kapalı (her bölüm tek kavram öğretir). Uyarı süresi 0,67 → 1,2 sn.
- Rüzgâr ×0,62 ve yanal sürüklenme 1,6: balon köşeye savrulup kurtulamıyordu.
- Duvar sürtünmesi 0,9 → 0,985 (iterasyon başına) ve huni eğimi en az ~33°: balon yatık eğimlerde takılıyordu.
- Kaygan kapı ağızları (lip_slip): balon sivri köşede dengede kalıp takılıyordu.
- Dikenli boğaz: 40 px dikensiz yaka, genişlik 150 (tanıtımda 160), uzunluk ≤ 120.
- "Takıldın" gerçek oyunda başarısızlık değil; sadece doğrulayıcı 15 sn limit kullanır.

## D12 — Yapımcı "her şeye onay" verdi · 2026-11-26
- Android SDK lisansları kabul edildi; M3–M8'deki GATE'ler (stil seçimi dahil) Claude tarafından karara bağlandı ve gerekçelendirildi.
- Yine de **para harcama, hesap açma ve mağazaya yükleme yapılmadı**: bunlar yapımcının kimliği ve hesabıyla yapılmak zorunda (docs/LAUNCH.md).

## D13 — GATE 2 (sanat yönü): varsayılan "Kâğıt Kesik" · 2026-11-26
- Alternatifler: Neon Gece (en çarpıcı, ama hiper-gündelikte yaygın), Pastel Gün (sevimli, ama ayırt edici değil).
- Gerekçe: Kâğıt doku + mürekkep kontur + gölgeli şeritler, mağazada sıradan AI görsellerinden ve neon klonlardan ayrışıyor, sıcak ve okunaklı. Diğer iki stil oynayarak (25★ / 40★) veya "Tüm temalar" IAP'ıyla açılan kozmetikler oldu (meta + gelir).

## D14 — Reklam/ödeme için kendi Android eklentimiz (SisPlatform) · 2026-11-26
- Topluluk eklentileri (poing-studios AdMob, GodotGooglePlayBilling) GitHub sayfaları proxy'de 403 verdiği için indirilemedi. Maven erişimi vardı.
- Kotlin Godot v2 eklentisi: UMP onayı → AdMob (ödüllü + geçiş), Play Billing 9.1 (satın alma, onaylama, geri yükleme), paylaşım, uygulama içi değerlendirme. Tek AAR (`game/addons/sis_platform/bin`), kaynak `android_plugin/`.
- AdMob 25.5 Kotlin 2.3 meta verisiyle geliyor, şablon Kotlin 2.1: `-Xskip-metadata-version-check` (API Java olduğu için güvenli).
- Eklenti yoksa (masaüstü/test) `Platform` servisi sahte moda geçer: debug'da ödüllü reklam "başarılı", release'de görünmez (asla bozuk düğme yok).

## D15 — Reklam politikası (oyunda kodlandı) · 2026-11-26
- Geçiş reklamı: 10. bölümden önce yok, ≥180 sn ve ≥2 bölüm arayla, sadece bölüm sonu geçişinde.
- Yama (ödüllü devam): deneme başına 1, ~1,5 sn geri sarar; yama kullanılan tur en fazla 1★ alır ve rekor kaydetmez.

## D16 — Günlük kuyu: önceden doğrulanmış havuz · 2026-11-26
- Cihazda prosedürel üretim + doğrulama pahalı ve riskli. Bunun yerine 60 prosedürel bölüm çevrimdışı üretildi, uzman bot çözdü, karma bot geçme oranı %30–86 bandında tutuldu (ortalama %64). Gün → havuz[gün mod 60]. Havuz araçla büyütülebilir (`tools/gen_daily.gd`).

## D17 — Analitik yalnızca cihazda (şimdilik) · 2026-11-26
- Firebase eklenmedi: ek SDK + `google-services.json` (yapımcının Firebase projesi) + Veri Güvenliği güncellemesi gerektirir. Olay şeması hazır (KPI.md); uzak analitik yumuşak lansmandan önce eklenmeli (yapımcı kararı).

## D18 — Paket adı `com.palmandmore.sis`, sürüm 1.0.0 (kod 1) · 2026-11-26
- İlk Play yüklemesinden sonra değiştirilemez. Repo adından türetildi; yapımcı farklı isterse ilk yüklemeden önce değiştirilmeli.

## D19 — Yükleme anahtarı · 2026-11-26
- 4096-bit RSA, 10000 gün, `secrets/` (git'te yok). Play App Signing kullanılacağı için kaybolursa Play Console'dan sıfırlanabilir. Yine de iki yerde yedeklenmeli.

## D20 — 15 dil, çeviriler veri dosyasında · 2026-11-26
- Yapımcı isteği: İngilizce + daha fazla dil. Diller: tr, en, es, pt, id, hi, de, ja, **fr, it, ru, ko, zh (basitleştirilmiş), vi, th**. Desteklenmeyen sistem dili → İngilizce.
- Çeviriler `game/data/i18n.json` (anahtar → dil → metin): bölüm adları ve tema adları dahil; oyunda Türkçe kalan metin yok. Test: her anahtar her dilde dolu, `%d/%s` sayıları İngilizceyle aynı.
- Ayarlar → Dil paneli: ana dildeki adlar + "sistem dili" seçeneği.
- Arapça eklenmedi: sağdan sola düzen için arayüz aynalama gerekiyor (ayrı iş). Çince geleneksel (zh_TW/HK) basitleştirilmiş görür.
- Çeviriler makine kalitesinde değil ama ana dili konuşan biri tarafından gözden geçirilmedi: DOĞRULANMADI. Kapalı testte ilgili ülkelerden testçilerle kontrol edilmeli.

## D21 — Yazı boyutu ayarı · 2026-11-26
- Normal / Büyük (×1,15) / Çok büyük (×1,3). Bütün metin çağrıları ölçekleniyor; kutusuna sığmayan metin otomatik küçülüyor (`UI.fit`). Ayarlar paneli 9 satıra kadar sığacak şekilde sıkıştırıldı.

## D22 — Firebase Analytics, yapılandırmaya bağlı · 2026-11-26
- Eklenti, `google-services.json` ve Gradle eklentisi olmadan, kimliklerle manuel başlatıyor (`initFirebase`). Kimlikler boşsa SDK pakete girmiyor.
- Gizlilik: manifest'te `firebase_analytics_collection_enabled=false`; UMP onayı tamamlanınca `can_request_ads` true ise açılıyor. Reklam kişiselleştirmesi için kullanılmıyor.
- Crashlytics eklenmedi (Gradle eklentisi + mapping gerekir); çökme/ANR için Play Console Android Vitals kullanılacak.
- `session_start` Firebase'de ayrılmış ad → `app_session`. Test: ayrılmış adlar kullanılmıyor.
- Doğrulama: sahte kimliklerle derleme → manifest bayrağı ve Firebase sınıfları pakette. Gerçek veri akışı DOĞRULANMADI (gerçek proje + telefon gerekiyor).

## D23 — Kampanya 15 → 50 bölüm (üretilmiş + doğrulanmış) · 2026-11-26
- 16–50: `LevelGen` el yapımı bölümlerin kalıplarını (rüzgâr kayması, ritim, boğaz, dikenli boğaz, tavan, ters rüzgâr) zorluk d ile ölçeklenen modüllere çevirir. 72 aday üretildi; her biri uzman planlayıcıyla çözüldü ve 10 botla ölçüldü. `scripts/select_levels.py` 35'ini hedef eğriye göre seçti (%85 → %25; her dünyanın ilk bölümü kolay; par > 35 sn cezalı).
- 12 koşuluk doğrulama: 17. bölümde %75 → 50. bölümde %8 (gürültü ±%14). Uzman 50/50 (otomatik test).
- 16+ bölümler 5'erli 7 dünyada ve dünya adıyla gösteriliyor (Rüzgâr Vadisi… Son Nefes, 15 dil). Ana menü ızgarası 15'lik sayfalara bölündü, sıradaki bölümün sayfasında açılıyor.
- Sınır: üretilmiş bölümlerde el yapımı bölümlerdeki "tek fikir öğret" kurgusu yok; insan testinde sıkıcı/haksız bulunanlar elle düzeltilecek.

## D24 — "Günlerce, günde saatlerce oynanabilir" isteği · 2026-11-26
- **Sınırsıza yakın kampanya:** 50 bölümden sonra ~950 bölümlük, çevrimdışı üretilmiş ve her biri uzman bot tarafından çözülmüş banka (`data/levels/bank.json`). Banka bitince aynı bölümler ayna görüntüsüyle ikinci tur (fizik simetrik → çözülebilirlik korunuyor, test ediliyor). Toplam ~1950 bölüm; par ortalaması ~25 sn → saf oyun ~13 saat, tekrar denemelerle onlarca saat. Zorluk: yavaş yükselen ortalama + 10 bölümlük dalga (zor bölümlerden sonra nefes aldıran bölümler).
- Dünya adları 7'li döngüde tekrar eder, kademe numarasıyla: "Rüzgâr Vadisi 2", "… 3".
- **Enerji/can sistemi yok:** oyuncu istediği kadar oynar (karanlık kalıp yok).
- Not: "sonsuz koşu" yasağı türün klonunu kapsar; burada her bölüm ayrı, bitişi olan, tasarlanmış bir bulmaca. Sonsuz akan tek bölüm yok.

## D25 — Jeton ekonomisi ve günlük görevler · 2026-11-26
- Kazanç: bölüm başına 5 + 5×yıldız (tekrar oynamak da kazandırır), günün ilk günlük kuyusu +50, görev 40–120, tüm görevler +100, sonuçta isteğe bağlı ödüllü reklam "2× jeton".
- Harcama: 12 jetonlu balon (150–1200), temalar (Neon Gece 1500, Pastel Gün 2500; yıldızla ücretsiz açılma yolu ve IAP sürüyor). Satın alma iki dokunuşla (yanlışlıkla harcama yok).
- Günlük görevler: 6 türden 3'ü (bölüm, yıldız, sıkışma, günlük kuyu, 3★, kıl payı); tarih tohumlu → herkese aynı, yeniden başlatmada sabit. Rozet sayacı ana menüde.
- Denge tahmini: saatte ~10 bölüm × ~15 jeton ≈ 150 + görevler ~250/gün → en pahalı balon (disko) ~3–4 günlük düzenli oyunla. Gerçek veriyle ayarlanacak.
