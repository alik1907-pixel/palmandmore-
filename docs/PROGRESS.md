# PROGRESS.md — Milestone durumu

_Son güncelleme: 2026-11-26_

## Özet
Kod, içerik, mağaza materyali ve yayın paketi hazır. Kalan işlerin hepsi yapımcının kimliği, hesabı ya da cihazını gerektiriyor: Play Console, AdMob, gizlilik politikasını yayınlama, telefon testi, 12 kişilik kapalı test. Adım adım rehber: **docs/LAUNCH.md**.

## M0 — Ortam: TAMAM
- Godot 4.7.2, Android SDK (platform 36, build-tools 36), Gradle şablonu, debug ve yükleme anahtarları.
- Çıktılar: `build/android/sis-debug.apk` (hızlı, eklentisiz), `sis-gradle-debug.apk` (eklentili, telefon testi), `sis-release.aab` (imzalı, Play'e yüklenecek).
- Emülatör yok (bulut makinede KVM yok) → cihaz testi yapımcıda.

## M1 — Fikir: TAMAM (GATE 1 → ŞİŞ)

## M2 — Dikey dilim: TAMAM (cihaz ölçümleri hariç)
- Deterministik yumuşak gövde simülasyonu, 15 el yapımı bölüm, juice, sentez sesler, yazısız öğretici.
- Planlayıcı botla doğrulama: uzman 15/15; karma popülasyon B1–9 %92–100 → B15 %22,5.
- [ ] Telefonda 60 FPS ve girdi gecikmesi: DOĞRULANMADI.

## M3 — Sanat ve ses: TAMAM (GATE 2 → Kâğıt Kesik, D13)
- 3 tema (Kâğıt Kesik varsayılan; Neon Gece, Pastel Gün açılabilir), prosedürel arka plan shader'ı, ikon seti (512, 192, adaptif ön/arka plan).
- 10 prosedürel balon kostümü, 4 katmanlı uyarlanabilir sentez müzik.
- Erişilebilirlik: ses/müzik/titreşim ayrı ayrı kapatılabilir, tek elle oynanır, diken = renk + şekil (sadece renge dayanmaz). Yazı boyutu ayarı var (D21).

## M4 — Tutma ve meta: TAMAM (uzak analitik ve lig hariç)
- **15 dil** (D20): arayüz, bölüm ve tema adları, paylaşım metinleri, mağaza metinleri; Ayarlar → Dil paneli. Ana dil kontrolü DOĞRULANMADI.
- Ana menü (canlı maskot), bölüm ızgarası, ★ sistemi (par = uzman süresi), günlük kuyu (60 doğrulanmış bölüm), seri, kostüm/tema kilitleri, paylaşım metni (8 dil), değerlendirme isteği.
- Olay şeması uygulandı (KPI.md), olaylar cihazda tutuluyor.
- [ ] Haftalık lig / küresel patlama ısı haritası: backend gerekir (D17). Olaylar konumla kaydediliyor.
- [x] **~1950 bölümlük kampanya**: 15 el yapımı + 35 seçilmiş + 952 bankadan (her biri uzman botla çözüldü) + aynalı ikinci tur; ortalama par 25,6 sn. 60 günlük kuyu ayrıca (D23, D24).
- [x] **Jeton ekonomisi + günlük görevler + jeton mağazası** (12 yeni balon, temalar jetonla), "2× jeton" ödüllü reklamı; enerji/can yok (D25).
- [x] **Yazı boyutu ayarı** (Normal/Büyük/Çok büyük, taşan metin otomatik küçülür) (D21).
- [x] **Firebase Analytics** köprüsü hazır; yapımcının Firebase kimlikleriyle açılır (D22, LAUNCH §2b).

## M5 — Gelir: TAMAM (test kimlikleriyle)
- SisPlatform Android eklentisi: UMP onayı, AdMob ödüllü + geçiş reklamı, Play Billing (3 ürün, onaylama, geri yükleme), paylaşım, uygulama içi değerlendirme.
- Reklam politikası kodda (D15). Ekonomi: ECONOMICS.md.
- [ ] Gerçek AdMob kimlikleri ve Play ürünleri: yapımcı hesabı gerekiyor (LAUNCH §1–3).
- [ ] Ek mediation ağları: AdMob paneli + adaptör bağımlılığı (sonra).

## M6 — Kalite: TAMAM (cihaz ölçümleri hariç)
- 24 otomatik test yeşil (50 bölüm + banka örneklemi + aynalıları uzman tarafından çözülüyor, ayna yansıması, görev/mağaza ekonomisi, çeviri, Firebase kapısı, yazı sığdırma): replay determinizmi, kurallar, 15 bölüm + günlük havuz örneklemi çözülebilir, profil/seri kuralları, i18n tamlığı, yapılandırma.
- Uçtan uca arayüz öz-testi (`-- selftest`) yeşil, çıkışta sızıntı yok.
- Android davranışları: geri tuşu, arka plana atılınca basılı tutmanın bırakılması, çoklu parmak, atomik kayıt.
- AAB 57 MB (iki mimari; cihaz başına ~25–30 MB indirme, tahmin).
- [ ] adb ölçümleri (soğuk açılış, monkey, bellek), Android Vitals: telefon + Play ön lansman raporu gerekiyor.

## M7 — Mağaza ve politika: HAZIR (yükleme yapımcıda)
- 15 dilde mağaza metni (sınırlar kodla doğrulandı), ekran görüntüleri TR/EN (8'er), öne çıkan görsel TR/EN, 30 sn tanıtım videosu TR/EN, ikon 512.
- Gizlilik politikası (TR/EN), beyan cevapları, Veri Güvenliği, kapalı test planı ve geri bildirim formu: LAUNCH.md.
- [ ] Gizlilik politikasının herkese açık URL'si, geliştirici e-postası, (önerilen) alan adı + app-ads.txt.

## M8 — Büyüme: ARAÇLAR HAZIR
- Yönetmen modu (`scripts/director.py`): tarif başına otomatik tur bulma → kayıt → olay anına göre kesme → kanca başlığı → klip + paylaşım metni (`media/clips/clips.csv`).
- Yayıncı sunumu taslağı: PUBLISHER_PITCH.md (yumuşak lansman verisiyle doldurulacak).
- [ ] Kapalı test (12 kişi × 14 gün) → yumuşak lansman → KPI kapıları: yapımcı hesabı ve zaman gerekiyor.

## Bilinen eksikler ve riskler
- Bot ≠ insan: ilk 9 bölüm botlara göre kolay; gerçek veriyle ayarlanacak.
- Hindi/japonca/çince/tayca glifler Android sistem fontuna dayanıyor (cihazda DOĞRULANMADI).
- Repo kökündeki boş Expo dosyaları duruyor (yapımcı karar vermedi).
