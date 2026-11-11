# Kabin — Senin Yapman Gerekenler

> Şimdilik **hiçbir şey açma**. Önce Aşama 0 dokümanlarını onayla. Her hesabı, ihtiyaç duyduğumuz aşamada
> adım adım, tek tek tarif edeceğim ve bitirmeni bekleyeceğim. Bu dosya sana genel resmi ve parayı gösterir.
>
> Genel kurallar:
> - Şifreleri ve API anahtarlarını **asla sohbete yapıştırma**. Anahtar gerektiğinde sana güvenli bir form açtıracağım
>   ya da Supabase panelindeki "Secrets" bölümüne nasıl gireceğini tarif edeceğim.
> - Mümkün olan her yerde iki adımlı doğrulamayı (2FA) aç.
> - Proje için ayrı bir e-posta adresi açman iyi olur (ör. kabin.app.iletisim@…); tüm hesaplar ona bağlanır.

## Sıralı liste

| Sıra | Ne | Ücret | Ne zaman | Neden |
|---|---|---|---|---|
| 1 | **Proje e-postası** | Ücretsiz | Hemen (onaydan sonra) | Tüm hesaplar tek adreste |
| 2 | **Expo hesabı** (expo.dev) | Ücretsiz (ileride 19 $/ay Starter) | Aşama 1 | Uygulamayı derleyip telefonuna kurmak |
| 3 | **Supabase hesabı** (supabase.com) | Geliştirmede ücretsiz; yayından önce **25 $/ay** | Aşama 1 | Veritabanı, giriş, depolama, sunucu fonksiyonları. Bölge: Frankfurt |
| 4 | **Google Play Console** | **25 $ tek sefer** | Aşama 1–2 | Android test ve yayın. Kimlik doğrulaması birkaç gün sürebilir, erken başlamak iyi |
| 5 | **Apple Developer Program** | **99 $/yıl** | iPhone'un varsa Aşama 1; yoksa Aşama 11 | iPhone'a kurulum, TestFlight, App Store |
| 6 | **OpenAI hesabı** (platform.openai.com) | Moderasyon ücretsiz | Aşama 3 | Fotoğraf ve metin moderasyonu |
| 7 | **FASHN hesabı** (fashn.ai, API) | Ön ödemeli kredi: başlangıç için ~20–50 $ | Aşama 4 | Ana AI deneme sağlayıcısı. **Otomatik yükleme kapalı** olacak |
| 8 | **Google AI Studio / Gemini API** | Kullandıkça (~5–20 $ test için) + **bütçe sınırı** | Aşama 4 | Yedek AI sağlayıcısı ve kör test |
| 9 | **Google Cloud projesi** (Safe Browsing) | Ücretsiz | Aşama 6 | Zararlı link kontrolü (8 ile aynı Google hesabı olabilir) |
| 10 | **Satış ortaklığı başvuruları** | Ücretsiz | Aşama 6 (onaylar haftalar sürebilir) | Aşağıdaki listeye bak |
| 11 | **Firebase projesi** (sadece bildirim anahtarı için) | Ücretsiz | Aşama 9 | Android'de push bildirimi |
| 12 | **AdMob hesabı** | Ücretsiz (sana para öder) | Aşama 9 | Ödüllü reklam. Ödeme için vergi ve banka bilgisi ister |
| 13 | **Alan adı** (ör. kabin.app — müsaitlik kontrol edilecek) | ~10–20 $/yıl | Aşama 11 öncesi | Gizlilik politikası ve destek sayfası adresi mağazalarda zorunlu |
| 14 | **Avukat (KVKK/GDPR)** | Teklif al | Aşama 11 öncesi | Aydınlatma metni, açık rıza metinleri, yurt dışı aktarım sözleşmesi + KVKK bildirimi, VERBİS kontrolü |
| 15 | **Mali müşavir** | Değişir | Gelir başlamadan önce | Reklam ve satış ortaklığı geliri için şirket/vergi durumu |
| 16 | **Logo tasarımcısı** (isteğe bağlı) | ~50–300 $ | Aşama 11 öncesi | Geçici simgeyi profesyonelle değiştirmek |
| 17 | **12 test kullanıcısı** (şahıs Google hesabıysa) | Ücretsiz | Aşama 11, 14 gün sürer | Google Play'in yeni şahıs hesaplarına zorunlu kapalı testi |

**Yayına kadar zorunlu toplam:** 25 $ (Google) + 99 $ (Apple) + ~15 $ (alan adı) + ~50–100 $ AI kredisi + avukat.
**Yayından sonra aylık:** bkz. MALIYET.md (100 kullanıcıda ≈ 110 $/ay).

## Önemli kararlar (hesap açmadan önce)

1. **Şahıs mı şirket mi?** Apple'da şahıs hesabında mağazada satıcı olarak **senin adın** görünür; şirket hesabı
   için D-U-N-S numarası (ücretsiz, ~1–4 hafta) gerekir. Google'da şirket hesabı "12 test kullanıcısı / 14 gün"
   kuralından muaf. Reklam/satış ortaklığı geliri vergilendirilir → mali müşavire sor.
2. **Hangi telefonda test edeceksin?** Android ise Aşama 1'de sadece Expo + Supabase yeter. iPhone ise Apple hesabı
   (99 $) Aşama 1'de gerekir.

## Satış ortaklığı başvuru listesi (Aşama 6'da birlikte bakacağız)

Bu programların Türkiye koşullarını aramalarda net doğrulayamadım; başvuru zamanı her birinin resmi sayfasını
birlikte kontrol edeceğiz. Çoğu, başvuruda yayında bir web sitesi veya uygulama görmek ister — bazılarına yayından
sonra başvurmak gerekebilir.

- **Türkiye:** Amazon.com.tr Ortaklık Programı, Trendyol (influencer/affiliate programı), Hepsiburada (varsa),
  Türk satış ortaklığı ağları (ör. Gelir Ortakları, ReklamAction, Admitad — birçok mağazayı tek hesapla kapsar)
- **Global:** Amazon Associates (ABD/AB), AWIN, Rakuten Advertising, Impact, Skimlinks/Sovrn (herhangi bir
  mağaza linkini otomatik dönüştüren servisler — mobil uygulama kabul edip etmedikleri kontrol edilecek)

## Bu bulut oturumuyla ilgili teknik not

Benim çalıştığım bulut ortamının internet erişimi kısıtlı: npm (paket deposu) açık, ama expo.dev, supabase.com ve
fashn.ai şu an kapalı. Aşama 1'de uygulamayı derleyip Supabase'e yüklemek için bu adreslere erişim gerekecek.
O an geldiğinde sana bir onay ekranı çıkacak; ne açtığımı ve nedenini önceden yazacağım.
