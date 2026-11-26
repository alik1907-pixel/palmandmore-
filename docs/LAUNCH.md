# LAUNCH.md: Yayın rehberi (yapımcının yapacakları + hazır olanlar)

Bu bulut oturumu Play Console'a, AdMob'a veya senin hesaplarına giriş yapamaz. Bu adımlar senin hesabınla yapılmalı. Her adım için gereken dosya hazır; yol belirtildi.

## 0. Hazır olanlar
| Ne | Nerede |
|---|---|
| İmzalı yayın paketi (AAB, v1.0.0, kod 1, hedef API 36) | `scripts/build_release.sh` → `build/android/sis-release.aab` |
| Telefon test APK'sı (reklam/ödeme eklentisi dahil, debug imzalı) | `build/android/sis-gradle-debug.apk` |
| Yükleme anahtarı (upload key) | `secrets/upload.keystore` + `secrets/keystore.properties` (**git'te yok; sana ayrıca gönderildi. İki yerde yedekle.**) |
| Mağaza metinleri (15 dil) | `docs/STORE_LISTING.md` |
| İkon 512, öne çıkan görsel 1024x500, 8 ekran görüntüsü (TR/EN), 30 sn tanıtım videosu | `media/store/` |
| Gizlilik politikası (TR/EN) | `docs/privacy.html` |
| Paket adı | `com.palmandmore.sis` (Play'e ilk yüklemeden sonra **değiştirilemez**; değiştirmek istersen ilk yüklemeden önce söyle) |

## 1. Hesaplar (senin yapacağın)
1. **Google Play Console** geliştirici hesabı (25 $, kimlik doğrulama). Kişisel hesap → kapalı test şartı geçerli (bkz. §5).
2. **AdMob** hesabı → uygulama ekle (Android, henüz yayında değil) → 2 reklam birimi oluştur: *Ödüllü* ("patch_rewarded"), *Geçiş* ("level_interstitial").
3. AdMob → **Privacy & messaging** → GDPR mesajı + ABD eyalet düzenlemeleri mesajı oluştur ve yayınla (UMP formu buradan gelir).
4. **Gizlilik politikasını herkese açık bir adrese koy.** Seçenekler: GitHub Pages (`docs/privacy.html`), Google Sites veya kendi alan adın. `[GELİŞTİRİCİ E-POSTASI]` alanını doldur.
5. **app-ads.txt:** AdMob, Play listesindeki "geliştirici web sitesi" alanında bir alan adı ister ve kökte `app-ads.txt` arar. Alan adın yoksa reklam geliri sınırlanabilir. Basit bir alan adı + GitHub Pages yeterli. DOĞRULANMADI: AdMob'un güncel zorunluluk düzeyi.

## 2. Gerçek kimlikleri koyma (bana söyle, ben yaparım ya da sen düzenle)
`game/data/platform.json`:
- `admob_app_id` → AdMob uygulama kimliğin (`ca-app-pub-XXXX~YYYY`)
- `rewarded_unit`, `interstitial_unit` → reklam birimi kimliklerin
- `test_ads` → `false`
- `privacy_url`, `store_url` → gerçek adresler
Sonra: `scripts/build_release.sh`. **Test kimlikleriyle canlıya çıkma; kendi reklamına asla tıklama.**

## 3. Play Console: uygulama oluşturma
- Uygulama adı: "ŞİŞ: Balon Sıkıştırma", varsayılan dil Türkçe, Oyun, Ücretsiz.
- **Uygulama içi ürünler** (Ürünler → Uygulama içi ürünler), kimlikler birebir:
  - `remove_ads`: "Reklamları kaldır", önerilen 2,99 $
  - `theme_pack`: "Tüm temalar", önerilen 1,99 $
  - `cosmetic_pack`: "Gökkuşağı balon", önerilen 0,99 $
- **Mağaza girişi:** STORE_LISTING.md metinleri + media/store görselleri (TR ve EN görsellerle; diğer 13 dil metin olarak, görseller EN setiyle).

## 4. Uygulama içeriği beyanları (önerilen cevaplar)
| Beyan | Cevap |
|---|---|
| Gizlilik politikası | §1.4'teki URL |
| Reklam içeriyor mu | **Evet** |
| Uygulama erişimi | Tüm işlevler kısıtlama olmadan kullanılabilir (giriş yok) |
| İçerik derecelendirme (IARC) | Kategori: Oyun. Şiddet: yok (balon patlaması karikatür efekt, karakter zarar görmüyor). Cinsellik/dil/madde/kumar: yok. Kullanıcı etkileşimi/içerik paylaşımı: yok (sadece sistem paylaşım menüsü). Dijital satın alma: **var**. Beklenen sonuç: PEGI 3 / ESRB Everyone. DOĞRULANMADI: anketin güncel soru metinleri. |
| Hedef kitle | **13–15, 16–17, 18+** (13 altı seçilmez → Aileler programı dışı). "Çocuklara hitap ediyor mu?" → Hayır. |
| Reklam kimliği | **Evet**, reklam ve analiz için (AdMob) |
| Veri güvenliği | Aşağıda |
| Haber uygulaması / COVID / Devlet / Finans | Hayır |

**Veri güvenliği formu (AdMob SDK'sının topladıklarına göre):**
- Toplanan ve paylaşılan: *Konum → Yaklaşık konum* (IP üzerinden), *Uygulama bilgileri ve performansı → Kilitlenme günlükleri, Teşhis*, *Cihaz veya diğer kimlikler → Reklam kimliği*. Amaç: Reklam veya pazarlama, Analiz, Dolandırıcılık önleme/güvenlik. Paylaşılan taraf: Google (AdMob).
- *Uygulama etkinliği → Uygulama etkileşimleri*: AdMob reklam etkileşimlerini toplar. Google'ın AdMob veri beyanı rehberine göre işaretle (DOĞRULANMADI: güncel liste; https://developers.google.com/admob/android/privacy/play-data-disclosure).
- Aktarım sırasında şifreleme: Evet. Kullanıcı veri silme talebi: Geliştirici hesabı/sunucu verisi yok → yalnızca cihazda.
- Satın alma geçmişi: Google Play işler; geliştirici toplamaz.

**İzinler:** INTERNET, ACCESS_NETWORK_STATE, VIBRATE, AD_ID (AdMob). FOREGROUND_SERVICE ve DUMP satırları Google kütüphanelerinden (WorkManager / profileinstaller) gelir; ön plan hizmeti türü beyanı gerekmez. DOĞRULANMADI: Play Console'un bu satırlar için soru sorup sormadığı.

## 5. Kapalı test (yeni kişisel hesaplar için zorunlu)
- **En az 12 test kullanıcısı, kesintisiz 14 gün** (resmi kural, bkz. RESEARCH.md §5). 14 gün dolunca üretim erişimine başvurulur; otomatik açılmaz.
- Plan: 15–20 kişiyle başla (bırakanlar olur). Test kanalı: "Kapalı test – Alfa", Google Grubu veya e-posta listesi.
- Test kullanıcılarından istenecek: günde en az bir oturum; Günlük Kuyu'yu oynamak (seriyi koruma = doğal günlük dönüş); hata/fikir bildirimi.
- **Geri bildirim formu soruları (Google Forms):**
  1. Cihaz modeli / Android sürümü
  2. İlk bölümü talimat okumadan anladın mı? (Evet / Kısmen / Hayır)
  3. En çok takıldığın bölüm ve nedeni
  4. Oyun hissi: 1–5 (balonun ağırlığı, tepki hızı)
  5. Ses ve müzik: 1–5
  6. Reklamlar rahatsız etti mi? (Hiç / Biraz / Çok)
  7. Bir arkadaşına önerir misin? 0–10
  8. Hata veya çökme yaşadın mı? Ne oldu?
- Üretim başvurusu cevapları için not tut: test süresince düzeltilen hatalar, değişen bölümler (PROGRESS.md'den).

## 6. Yumuşak lansman (üretim erişiminden sonra)
- Ülkeler: Türkiye (ana dil + ucuz kitle), Filipinler, Brezilya. DOĞRULANMADI: güncel CPI farkları.
- 2–3 hafta, hedefler KPI.md'de. Kapı geçilmezse: veriden 3 hipotez → değişiklik → yeni sürüm (en fazla 3 iterasyon).
- Ücretli test bütçesi (isteğe bağlı): kreatif başına 50–100 $ (TikTok/Meta) → CPI ve tıklama oranı. **Bu adım para harcar; ayrıca onayını isterim.**

## 7. Sürüm çıkarma kontrol listesi
- [ ] `game/data/platform.json` gerçek kimlikler, `test_ads=false`
- [ ] `export_presets.cfg` → `version/code` +1, `version/name`
- [ ] `game` içinde testler: `godot --headless --path . -s res://tools/run_tests.gd` → 0 hata
- [ ] `scripts/build_release.sh` → AAB
- [ ] Play Console → iç test kanalına yükle → ön lansman raporu (çökme/ANR) temiz
- [ ] Kapalı teste terfi
