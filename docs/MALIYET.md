# Kabin — Maliyet Tahmini

> Durum: **Taslak v0.1 — onay bekliyor** · Tarih: 11 Kasım 2026 · Para birimi: ABD doları ($)
>
> **Dürüstlük notu:** Fiyatlar 11 Kasım 2026'da web aramasıyla toplandı. Bu oturumun ağ kısıtı yüzünden
> sağlayıcıların resmi fiyat sayfalarını doğrudan açamadım; bir kısmı resmi doküman alıntısı, bir kısmı üçüncü
> taraf fiyat izleyicileri. Kullanım varsayımları (kullanıcı başına deneme sayısı vb.) **tahmindir**. TL karşılıkları
> kur değiştiği için yazılmadı. Ödeme yapmadan önce her kalemi resmi sayfadan birlikte kontrol edeceğiz.

## 1. Deneme başı maliyet

| Kalem | FASHN v1.6 (önerilen ana) | Nano Banana 2.1 (yedek/ucuz) | Not |
|---|---|---|---|
| AI üretimi | 0,075 $ | ~0,034 $ çıktı + görsel girdi ücreti ≈ **0,04 $** | FASHN: 1 kredi; taahhütlü paketlerde 0,049 $'a iniyor |
| Moderasyon (girdi + çıktı) | 0 $ | 0 $ | OpenAI moderasyon ücretsiz |
| Depolama (~0,4 MB sonuç) | < 0,0001 $ | < 0,0001 $ | Supabase Pro dahil kotada |
| Sunucu fonksiyon çağrıları (~10) | ~0,00002 $ | ~0,00002 $ | Ayda 2 milyon çağrı Pro'ya dahil |
| Sonucun indirilmesi (trafik) | ~0,00004 $ | ~0,00004 $ | |
| **Toplam / deneme** | **≈ 0,075 $** | **≈ 0,04 $** | Başarısız istek FASHN'da ücretsiz, kullanıcıya hak iadesi |
| "Bende Dene" tam kombin (2 çağrı) | ≈ 0,15 $ | ≈ 0,08 $ | Kullanıcıdan 1 hak düşer, fark bizde |
| Önbellekten dönen tekrar | 0 $ | 0 $ | |

Karşılaştırma için: Google Vertex Try-On ~0,06 $ (emeklilik riski), OpenAI gpt-image-1.5 orta kalite 0,034 $,
FASHN Try-On Max 0,15–0,375 $ (premium için).

## 2. Kullanım varsayımları

| Varsayım | Değer | Gerekçe |
|---|---|---|
| Aylık aktif kullanıcı (MAU) başına deneme | **10** (düşük 5, yüksek 25) | Ayda ~8 aktif gün × günde ~1,2 deneme; çoğu kullanıcı 3 hakkın hepsini kullanmaz |
| Tam kombin (2 çağrılı) deneme oranı | %0 (temel), en kötü %30 | Kör testten sonra netleşecek |
| Gönderi görsel trafiği | kullanıcı başı ayda ~65 MB | 300 küçük görsel + 50 tam görsel |
| Saklama | Kaydedilmeyen deneme sonuçları 30 gün sonra silinir (öneri) | Depolama ve gizlilik |

## 3. Aylık tahmini maliyet (FASHN v1.6, MAU başı 10 deneme)

| Kalem | 100 kullanıcı | 1.000 kullanıcı | 10.000 kullanıcı |
|---|---|---|---|
| AI deneme (1.000 / 10.000 / 100.000 deneme) | 75 $ | 750 $ | 7.500 $ |
| Supabase Pro (8 GB veritabanı, 100 GB dosya, 250 GB trafik, 100.000 MAU dahil) | 25 $ | 25 $ | 25 $ |
| Supabase ek: güçlü sunucu + fazla trafik | 0 $ | 0 $ | ~40 $ |
| Expo EAS (derleme + uygulama güncellemesi) | 0 $ (Ücretsiz plan) | 19 $ (Starter) | 19 $ (+ gerekirse daha fazla, bkz. not) |
| Apple geliştirici (99 $/yıl ÷ 12) | 8 $ | 8 $ | 8 $ |
| Alan adı (~15 $/yıl) | 1 $ | 1 $ | 1 $ |
| Giriş e-postaları (SMTP servisi) | 0 $ | 0 $ | ~20 $ |
| Bildirim, moderasyon, hata takibi, Safe Browsing | 0 $ | 0 $ | 0 $ |
| **Toplam / ay** | **≈ 110 $** | **≈ 805 $** | **≈ 7.615 $** |
| Kullanıcı başı | 1,10 $ | 0,80 $ | 0,76 $ |

**Aynı tablo Nano Banana 2.1 ile:** ≈ **75 $ / 455 $ / 4.115 $**.
**FASHN taahhütlü fiyatla (0,049 $) 10.000 kullanıcıda:** ≈ **5.015 $**.

**Senaryo aralığı (FASHN):**

| MAU başı deneme | 100 | 1.000 | 10.000 |
|---|---|---|---|
| Düşük (5) | ~73 $ | ~430 $ | ~3.865 $ |
| Temel (10) | ~110 $ | ~805 $ | ~7.615 $ |
| Yüksek (25) | ~222 $ | ~1.930 $ | ~18.865 $ |

Notlar:
- Supabase Ücretsiz plan geliştirme için yeterli ama 1 hafta hareketsiz kalan projeyi durduruyor ve yedek yok →
  gerçek kullanıcıya açılmadan önce **Pro (25 $/ay)** şart.
- Expo'nun uygulama-içi güncelleme (EAS Update) kotası Ücretsiz'de 1.000, Starter'da 3.000 MAU. Aşarsak ya ek ücret
  ödenir ya da güncellemeler mağaza üzerinden yapılır (bedava, sadece daha yavaş). 10.000 kullanıcıda Production
  planı 199 $/ay — gerekirse o gün karar veririz.

## 4. Seni borca sokmayacak sigortalar

| Sigorta | Varsayılan | Etkisi |
|---|---|---|
| Kullanıcı başı günlük mutlak sınır | 6 AI çağrısı | Tek kullanıcı en fazla ~0,45 $/gün (~13,5 $/ay) |
| Ücretsiz hak | 3/gün | |
| Reklam hakkı | en fazla 2/gün | |
| **Tüm sistem günlük bütçe** | **10 $/gün** (başlangıç, sen belirlersin) | Aşılırsa deneme o gün kapanır, sana uyarı gelir. Ayda en fazla ~300 $. %80'e gelince önceden uyarı. 100 kullanıcı için bol; ~400 kullanıcıdan sonra yönetici panelinden yükseltmen gerekir (1.000 kullanıcı ≈ 25 $/gün) |
| Sağlayıcı tarafı | Ön ödemeli kredi, otomatik yükleme **kapalı** | Hesapta para biterse sadece deneme durur, fatura şişmez |
| Google Cloud / OpenAI | Bütçe uyarısı + harcama sınırı | Bulut hesabında sınırsız fatura riski kapatılır |
| Yeni hesap | ilk 24 saat 1 deneme (öneri) | Çoklu hesapla hak toplamayı caydırır |

## 5. Gelir tarafı — dürüst tablo

**Ödüllü reklam bir denemeyi finanse etmiyor.** Kaynaklar üst düzey pazarlarda (ABD vb.) ödüllü reklam için
1.000 gösterimde 10–30 $ diyor; Türkiye için resmi rakam bulamadım, benim tahminim 1.000 gösterimde 2–8 $.

| | Türkiye (tahmin) | ABD |
|---|---|---|
| Bir reklam izlemesinin geliri | 0,002–0,008 $ | 0,01–0,03 $ |
| Bir denemenin maliyeti (FASHN) | 0,075 $ | 0,075 $ |
| Bir denemeyi ödemek için gereken reklam | **10–38 reklam** | 3–8 reklam |

Sonuç: "1 reklam = +1 hak" her seferinde zarar ettirir (Türkiye'de deneme başı ~0,07 $). Günde 2 reklam sınırıyla
bu zarar kullanıcı başı ayda en fazla ~4 $ olur. Seçenekler PRD Açık Soru 3'te.

**Satış ortaklığı (çok kaba örnek):** 1.000 kullanıcı × ayda 0,5 tıklama × %2 satın alma × 40 $ sepet × %5 komisyon
≈ **ayda 20 $**. Yani MVP **zararına çalışacak**; MVP'nin amacı para kazanmak değil, insanların geri gelip
gelmediğini ölçmek. Gerçek gelir modeli (premium abonelik, sponsorlu tema) MVP sonrası.

## 6. Tek seferlik ve geliştirme maliyetleri

| Kalem | Tutar | Ne zaman |
|---|---|---|
| Google Play geliştirici hesabı | 25 $ (tek sefer) | Aşama 1–2 |
| Apple Developer Program | 99 $/yıl | iPhone'da test edeceksen Aşama 1, değilse yayın öncesi |
| AI kör testi (20 görsel × 2 sağlayıcı) | ~5 $ | Aşama 4 |
| Geliştirme sırasındaki denemeler | ~20–50 $ AI kredisi | Aşama 4–9 |
| Alan adı | ~10–20 $/yıl | Yayın öncesi (gizlilik politikası adresi için şart) |
| Logo / simge tasarımı (isteğe bağlı) | ~50–300 $ | Yayın öncesi |
| KVKK/GDPR hukuki inceleme | Avukata göre değişir — teklif al | Yayın öncesi |
| Supabase Pro | 25 $/ay | Gerçek kullanıcılara açılmadan önce |

## 7. Kaynaklar

- FASHN: [API sayfası](https://fashn.ai/products/api), [Genlook fiyat karşılaştırması](https://genlook.app/developers/vs/fashn), [Try-On Max değişiklik notu](https://fashn.ai/changelog/new-resolution-tiers-and-generation-mode-controls)
- Google: [Nano Banana fiyatları](https://benchlm.ai/media-pricing/nano-banana), [Nano Banana 2.1 fiyat değişikliği](https://fourweekmba.com/ai-google-halves-nano-banana-image-price-triples-input-price/), [Vertex Try-On izleyici](https://www.getmaxim.ai/bifrost/model-library/compare/vertex_ai/virtual-try-on-001)
- OpenAI: [GPT Image 1.5](https://developers.openai.com/api/docs/models/gpt-image-1.5), [Moderasyon ücretsiz](https://developers.openai.com/api/docs/guides/moderation)
- Supabase: [Fiyatlandırma](https://supabase.com/pricing), [üçüncü taraf özet](https://flexprice.io/blog/supabase-pricing-breakdown)
- Expo: [Planlar](https://docs.expo.dev/billing/plans/), [Expo EAS incelemesi](https://vibecoding.app/blog/expo-eas-review)
- Reklam: [MonetizeMore 2026](https://www.monetizemore.com/blog/admob-monetization/), [Appodeal eCPM raporu](https://appodeal.com/blog/mobile-ecpm-report-app-ad-monetization-worldwide-performance)
