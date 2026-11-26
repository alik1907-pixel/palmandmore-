# KPI.md — Hedefler ve ölçümler

## Hedefler (brief + RESEARCH.md §1–2)
| Metrik | Hedef | Ara kapı (yumuşak lansman 1. iterasyon) | Pazar referansı |
|---|---|---|---|
| D1 | ≥ %40 | ≥ %35 | Medyan ~%22–27; en iyi %10 ~%40 |
| D7 | ≥ %15 | ≥ %10 | Medyan ~%4; en iyi %10 ~%12 |
| D30 | ≥ %5 | ≥ %3 | Medyan ~%0,7 |
| Günlük oynama | ≥ 15 dk | ≥ 10 dk | — |
| CPTD3 (3 gün toplam oynama) | ≥ 5000 sn | — | Homa hibrit-gündelik kapısı |
| CPI (yumuşak lansman pazarı) | < 1,0 $ | — | Homa kapısı |
| Çökme / ANR | < %0,5 / < %0,2 | — | Google eşikleri: %1,09 / %0,47 |

## Ölçümler
| Tarih | Kaynak | Metrik | Değer | Not |
|---|---|---|---|---|
| 2026-11-26 | Bot (greybox) | Bölüm başarı eğrileri | CONCEPTS.md | İnsan verisi değil |
| 2026-11-26 | Planlayıcı bot, 40 koşu (M2) | Bölüm 1→15 kazanma | %97,5 → %22,5 | media/m2/levels_validation_40runs.jsonl; insan verisi değil |
| 2026-11-26 | Planlayıcı bot | Bölüm süresi (kazananlar) | 9,7–26,4 sn | Hedef 15–40 sn; ilk bölümler kısa |

## Analitik olay şeması (uygulandı: `game/src/services/analytics.gd`)
Olaylar cihazda `user://events.jsonl` dosyasına (son 3000 satır) yazılır ve eklentiye (`SisPlatform.logEvent`) iletilir. `platform.json` içinde Firebase kimlikleri doluysa olaylar **Google Analytics for Firebase**'e gider (onaydan sonra); boşsa sadece Logcat'e yazılır. Gizlilik politikası ve Veri Güvenliği eki hazır (LAUNCH §2b).
| Olay | Parametreler | Ne ölçer |
|---|---|---|
| app_session | sessions, day (kurulumdan beri gün) | D1/D7/D30, oturum sayısı (`session_start` Firebase'de ayrılmış ad) |
| consent | can_request_ads | Onay oranı (AB) |
| screen_home | stars | Menü dönüşleri |
| level_start | mode, level, attempt | Deneme sayısı, huni |
| level_complete | mode, level, attempt, sec, stars, continued | Geçme oranı, süre, yıldız |
| level_fail | mode, level, attempt, cause (spike/overinflate), x, y, progress, sec | **Patlama ısı haritası**, zorluk |
| level_quit | mode, level, progress | Bırakma noktaları |
| ad_offer_accept / ad_reward / ad_reward_fail | placement | Ödüllü reklam hunisi |
| ad_interstitial | – | Geçiş reklamı sıklığı |
| iap_click / purchase | product | IAP hunisi |
| share | – | Viral katsayı girdisi |
| skin_equip / theme_equip | skin / theme | Kozmetik ilgisi |
| language | lang, auto | Dil tercihleri (yerelleştirme önceliği) |
| text_size | scale | Erişilebilirlik ayarı kullanımı |
| coins_earn | amount, source (level/daily/mission/mission_bonus/double_ad) | Ekonomi akışı |
| mission_claim | reward | Görev tamamlama oranı |
| shop_buy | item, price | Jeton harcama, mağaza dönüşümü |

**Kapalı testte veri toplama:** Test kullanıcısından `adb pull /sdcard/Android/data/com.palmandmore.sis/files/...` istemek pratik değil. Kapalı test KPI'ları Play Console istatistiklerinden (yükleme, kaldırma, ANR, çökme) + geri bildirim formundan alınır. Yumuşak lansman için uzak analitik gerekir. Firebase entegrasyonu hazır; açmak için yapımcının Firebase projesinden 4 kimlik gerekiyor (LAUNCH §2b).
