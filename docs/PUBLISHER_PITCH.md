# ŞİŞ: Yayıncı sunumu (tek sayfa)

> **Kullanım:** Yumuşak lansman KPI'ları kapıları geçtiğinde, `[ ]` alanları gerçek verilerle doldurulur ve hibrit-gündelik yayıncılara (Homa, Voodoo, Supersonic, Kwalee, Rollic, Azur vb.) gönderilir. Bot verileri insan verisi değildir; sunumda yalnızca tasarım kanıtı olarak geçer.

**Tek cümle:** Tek tuşla şişip sönen jöle bir balonu dikenli, rüzgârlı, daracık bir kuyudan yukarı çıkar. Şişmek yükseltir ama büyütür; dar kapılardan ancak tam zamanında sönerek, momentumla kayarak geçilir.

**Neden şimdi:** Bulmaca pazarı merge/sort/match ile doymuş durumda (RESEARCH.md §3). ŞİŞ, tek girdiden iki çıktı (boyut = kaldırma + sığma + yelken) üreten bir fizik mekaniği. Mağazada benzeri bulunamadı (DOĞRULANMADI, negatif arama).

**Video kancası:** Sesi kapalı 3 saniyede anlaşılıyor: balon dar geçitte ezilip uzuyor, ya da dikene değip patlıyor. Örnek klipler: `media/clips/`, tanıtım: `media/store/promo_*_30s.mp4`.

**İçerik ve meta:**
- 15 el yapımı bölüm, her biri bir engel öğretiyor (huni, rüzgâr, diken, boğaz, dikenli boğaz, diken tavanı).
- Günlük kuyu: 60 doğrulanmış prosedürel bölüm, herkese aynı; seri sistemi ve paylaşım metni.
- 10 kostüm, 3 tema. Hepsi kodla üretiliyor; varlık maliyeti sıfır, yeni içerik çok hızlı.
- Bölüm üretim hattı: JSON format + uzman planlayıcı bot doğrulaması (her bölüm çözülebilir, zorluk eğrisi ölçülüyor).

**Teknik:** Godot 4.7, deterministik simülasyon (replay = 1 bit/kare), 60 Hz'de sim adımı ~80 µs. AAB 57 MB (cihaz başına ~25 MB). AdMob + UMP + Play Billing kendi Android eklentimizle. Otomatik testler (17), headless bot doğrulaması, otomatik video üretim hattı.

**Gelir:** Ödüllü "yama ile devam" (deneme başına 1, en fazla 1★), ödüllü kostüm, 10. bölümden sonra sınırlı geçiş reklamı, 3 IAP. Ayrıntılar: ECONOMICS.md.

**Metrikler (doldurulacak):**
| Metrik | Hedef | Ölçülen |
|---|---|---|
| CPI (ülke) | < 1,0 $ | [ ] |
| D1 / D7 | %40 / %15 | [ ] / [ ] |
| Günlük oynama | ≥ 15 dk | [ ] |
| CPTD3 | ≥ 5000 sn | [ ] |
| Bölüm 10 geçme oranı | ≥ %50 | [ ] |
| Günlük kuyu katılımı (DAU) | ≥ %30 | [ ] |

**İstek:** UA bütçesi + kreatif ekibi karşılığında gelir paylaşımı; ilk test haftası için 1 kreatif sprinti.
