# Kabin — Yapılacaklar

> Her aşamanın sonunda: (1) uygulama telefonunda çalışır + test tarifi, (2) testler yazılır ve çalışır,
> (3) git commit, (4) bu dosya güncellenir, (5) 5 cümlelik özet. **Onayın olmadan sonraki aşamaya geçilmez.**
>
> Durum işaretleri: `[ ]` yapılmadı · `[~]` devam ediyor · `[x]` bitti · `(SEN)` senin yapman gereken

## Aşama 0 — Planlama (kod yok) `[~]` onay bekliyor

- [x] docs/PRD.md — ürün tanımı, ekran ekran akışlar, açık sorular
- [x] docs/MIMARI.md — mimari, veri modeli, RLS, AI sağlayıcı karşılaştırması
- [x] docs/TASARIM.md — renk, tipografi, bileşenler, ekran listesi
- [x] docs/MALIYET.md — deneme başı ve aylık maliyet
- [x] docs/YAPILACAKLAR.md — bu dosya
- [x] docs/BENIM_ISLERIM.md — hesaplar, ücretler, sıra
- [x] CLAUDE.md — proje kuralları
- [ ] (SEN) Dokümanları oku, PRD §8'deki 16 soruyu cevapla, onay ver

## Aşama 1 — İskelet ve telefonda ilk açılış

Hedef: Telefonunda açılan, TR/EN boş ekranlar ve alt sekmelerden oluşan uygulama.
- [ ] Expo projesi (güncel kararlı SDK, TypeScript, Expo Router); boş dosyaları doldur, `firestore.indexes.json` sil
- [ ] Tasarım jetonları (renk, yazı tipi, boşluk), açık/koyu tema, temel bileşenler (Button, TextField, LabelBadge…)
- [ ] i18n altyapısı (TR/EN), cihaz diline göre başlangıç; eksik çeviri testi
- [ ] Alt sekme çubuğu + boş ekranlar (Akış, Hangisi?, Ekle, Tema, Profil)
- [ ] Supabase yerel geliştirme kurulumu, ilk migration (sadece `profiles` iskeleti)
- [ ] ESLint, Prettier, Jest; GitHub Actions'ta test çalıştırma
- [ ] Geliştirme derlemesi (Android APK / iPhone için Apple hesabıyla) ve telefona kurulum tarifi
- [ ] (SEN) Expo hesabı, Supabase hesabı; telefona kurulum ve test

## Aşama 2 — Kayıt, giriş, 18+, profil, rıza, hesap silme

- [ ] E-posta kodu ile giriş, Google ile giriş, Apple ile giriş (iOS)
- [ ] Doğum tarihi / 18+ kontrolü (sunucuda da doğrulanır)
- [ ] Sözleşme onayı + `consents` tablosu (sürümlü)
- [ ] Profil kurulumu (kullanıcı adı benzersizliği), ayarlar ekranı (dil, ülke, para birimi, beden sistemi)
- [ ] Hesabı sil (tüm veri + depolama) ve verilerimi indir
- [ ] `events` tablosu ve ilk olaylar (`signup_completed`, `app_opened`)
- [ ] RLS testleri (pgTAP): profiller, rızalar
- [ ] Geçici yasal metinler (taslak — avukat kontrolü gerektiği açıkça yazılı)

## Aşama 3 — Dijital ikiz

- [ ] Açık rıza ekranı (vücut fotoğrafı + yurt dışı aktarım), fotoğraf rehberi
- [ ] Kamera/galeri, kırpma, küçültme, EXIF silme, `bodies` özel kovasına yükleme
- [ ] Sunucu kontrolü: tek kişi, çıplaklık, çözünürlük (OpenAI moderasyon)
- [ ] Ölçüler ve tercihler formu; beden sistemi dönüşümleri + testleri
- [ ] RLS testleri: "başkası ikiz fotoğrafımı okuyamaz"
- [ ] (SEN) OpenAI hesabı (moderasyon için, ücretsiz)

## Aşama 4 — AI deneme çekirdeği

- [ ] Sağlayıcı soyutlama katmanı + `mock` sağlayıcı + FASHN + Gemini adaptörleri
- [ ] `credit_state` / `credit_ledger`, atomik hak düşme, iade, günlük sıfırlama
- [ ] `tryon-create` / `tryon-status`, önbellek anahtarı, takılı iş temizleyici (pg_cron)
- [ ] Kullanıcı başı mutlak sınır + sistem günlük bütçe sigortası + yönetici uyarısı
- [ ] Deneme hazırlık / bekleme / sonuç ekranları (önce-sonra sürgüsü)
- [ ] Kör test aracı: 20 örnek, iki sağlayıcı, isimsiz puanlama ekranı
- [ ] Testler: hak yarışı (aynı anda 10 istek → sadece 3 hak düşer), iade, bütçe kesmesi
- [ ] (SEN) FASHN ve Google AI Studio hesapları + az miktarda kredi; kör testi puanla; sağlayıcıya karar ver

## Aşama 5 — Paylaş menüsü ve filigranlı dışa aktarma

- [ ] iOS + Android paylaşım alma (sadece görsel) → Deneme hazırlık ekranı
- [ ] Filigranlı kaydet/paylaş, AI meta verisi
- [ ] (SEN) Instagram/tarayıcıdan paylaşarak test

## Aşama 6 — Akış, gönderi paylaşma, Bende Dene, ürün linkleri

- [ ] `posts`, `post_items`, `create_post` RPC (etiket kuralları), `posts` kovası RLS
- [ ] Gönderi moderasyonu (otomatik), "inceleniyor" durumu
- [ ] Akış (Yeni / Bugünün teması), gönderi detayı, profil sayfaları
- [ ] Bende Dene (gönderi → deneme), `allow_try_on` ayarı
- [ ] Link yönlendirici (`go`), Safe Browsing kontrolü, `affiliate_rules`, tıklama kaydı, satış ortaklığı açıklaması
- [ ] (SEN) Google Cloud projesi (Safe Browsing anahtarı, ücretsiz); satış ortaklığı başvuruları

## Aşama 7 — Şikayet, engelleme, moderasyon paneli

- [ ] Şikayet alt sayfası, 3 şikayette otomatik gizleme, şikayet edenin içeriği görmemesi
- [ ] İki yönlü engelleme (tüm sorgularda)
- [ ] Yönetici sekmesi: moderasyon kuyruğu, kaldırma, askıya alma
- [ ] RLS testleri: engelleme, askıya alma

## Aşama 8 — Hangisi? ve Günlük tema

- [ ] `next_pairs` / `cast_vote` RPC, oy kuralları, sonsuz akış, oran gösterimi
- [ ] Tema takvimi (yönetici), tema sekmesi, gönderim (günde 1), pg_cron ile kapanış ve sonuç hesabı
- [ ] Sonuç ekranı (kürsü, kullanıcının sırası)
- [ ] Testler: kendine oy yok, çift tekrar yok, süresi geçmiş çift reddi, sıralama hesabı

## Aşama 9 — Ödüllü reklam, seri, bildirimler

- [ ] AdMob ödüllü reklam + SSV fonksiyonu (imza doğrulama, tekrar engeli, günlük sınır)
- [ ] Seri hesaplama (gün sonu pg_cron), seri rozetleri
- [ ] Expo Push: tema, sonuç, seri hatırlatma, deneme hazır; bildirim tercihleri
- [ ] (SEN) AdMob hesabı; Firebase projesi (Android bildirim anahtarı); Apple push anahtarı

## Aşama 10 — Ölçüm paneli

- [ ] Tüm olayların eksiksiz kaydı (kayıt, deneme, oy, paylaşım, link tıklama)
- [ ] 1/7/30 gün geri dönüş kohort görünümü + günlük sayaçlar + AI harcaması
- [ ] Yönetici sekmesinde panel

## Aşama 11 — Mağaza hazırlığı ve yayın

- [ ] Yasal metinlerin son hali (avukat kontrolünden sonra), web sitesinde gizlilik politikası ve destek sayfası
- [ ] Uygulama simgesi, açılış ekranı, mağaza görselleri ve açıklamaları (TR/EN)
- [ ] Apple gizlilik etiketleri, Google Veri güvenliği formu, yaş derecelendirme anketleri
- [ ] Google Play kapalı test (şahıs hesabıysa 12 test kullanıcısı × 14 gün), TestFlight
- [ ] Yayın öncesi kontrol listesi (aşağıda) tamamen işaretli
- [ ] (SEN) Mağaza bilgileri, test kullanıcıları, son onay

## Yayın öncesi kontrol listesi

**Apple App Store**
- [ ] 1.2 Kullanıcı içeriği: otomatik filtre, her içerikte Şikayet, kullanıcı engelleme, uygulamada iletişim bilgisi, 24 saat içinde yanıt süreci
- [ ] 4.8 Apple ile giriş (Google ile giriş olduğu için)
- [ ] 5.1.1(v) Uygulama içinden hesap silme
- [ ] 5.1.1 Gizlilik politikası linki (uygulama içinde ve mağazada), toplanan veri listesi (gizlilik etiketleri)
- [ ] 5.1.2 Veri kullanımı: izinsiz takip yok; reklam kimliği kullanılırsa App Tracking Transparency izni
- [ ] Kamera ve fotoğraf izin açıklamaları (TR/EN, net amaç)
- [ ] Yaş derecelendirmesi: 18+, kullanıcı içeriği beyanı
- [ ] AI ile üretilen içerik etiketli; gerçek kişi görselinin rızasız düzenlenmesine karşı kurallar
- [ ] Ödüllü reklam isteğe bağlı, uygulama işlevi reklama kilitli değil
- [ ] İnceleme ekibi için demo hesap + hazır dijital ikiz

**Google Play**
- [ ] Kullanıcı içeriği politikası: kullanım koşulları, uygulama içi şikayet, engelleme, moderasyon
- [ ] Veri güvenliği formu (fotoğraflar, kişisel bilgiler, uygulama etkinliği; aktarım ve silme)
- [ ] Hesap silme: uygulama içi + web'den silme talebi bağlantısı
- [ ] İçerik derecelendirme anketi (kullanıcı içeriği, reklam)
- [ ] Reklam politikası: ödüllü reklam açık beyanlı, yanıltıcı yerleşim yok; Families/çocuk programı dışında
- [ ] Hedef kitle: 18+
- [ ] Yapay zekâ üretilen içerik politikası: kullanıcının AI çıktısını raporlayabilmesi
- [ ] Kapalı test şartı (şahıs hesabı)

**Yasal / gizlilik**
- [ ] KVKK aydınlatma metni, açık rıza metinleri, yurt dışı aktarım standart sözleşmeleri ve KVKK bildirimi
- [ ] GDPR: gizlilik politikası, veri işleme sözleşmeleri (Supabase, FASHN, Google, OpenAI)
- [ ] VERBİS kayıt yükümlülüğünün kontrolü (avukat)
- [ ] Satış ortaklığı açıklaması (reklam/ticari ilişki beyanı)
- [ ] Çerez/izleme yok beyanı veya gerekli izinler

**Teknik**
- [ ] Tüm RLS testleri yeşil, `service_role` anahtarı uygulamada yok (otomatik tarama)
- [ ] Günlük bütçe sigortası ve kullanıcı sınırı canlıda test edildi
- [ ] Sağlayıcı hesabında otomatik kredi yükleme kapalı
- [ ] Yedekleme açık (Supabase Pro), hata takibi açık
