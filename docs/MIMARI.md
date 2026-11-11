# Kabin — Mimari, Veri Modeli ve Güvenlik

> Durum: **Taslak v0.1 — onay bekliyor** · Tarih: 11 Kasım 2026
> Terimler ilk geçtiği yerde bir cümleyle açıklanır.

## 1. Teknoloji seçimi

| Katman | Seçim | Neden |
|---|---|---|
| Mobil uygulama | **Expo (React Native) + TypeScript + Expo Router** | Tek kod tabanıyla iOS + Android. Expo, React Native'in üstünde derleme, güncelleme ve yerel modül işlerini kolaylaştıran araç setidir. |
| Sunucu (backend) | **Supabase** (Postgres + Auth + Storage + Edge Functions + pg_cron) | Postgres'in **satır bazlı yetki** (RLS: veritabanının her satır için "bunu kim görebilir/değiştirebilir" kuralı) özelliği bu projenin gizlilik kurallarına birebir uyuyor. Ölçüm paneli için SQL ile geri dönüş hesabı kolay. |
| Sunucu fonksiyonları | **Supabase Edge Functions (Deno/TypeScript)** | API anahtarları sadece burada durur. Uygulama AI sağlayıcısını asla doğrudan çağırmaz. |
| Zamanlanmış işler | **pg_cron** | Postgres içinde "her gün 20:00'de şunu çalıştır" görevleri (tema kapanışı, bildirimler). |
| Bildirim | **Expo Push** (arkada APNs + FCM) | Ücretsiz, tek API ile iki platform. |
| Reklam | **Google AdMob ödüllü reklam** + **sunucu taraflı doğrulama (SSV)** | SSV: reklamı izleyen kullanıcıyı reklam ağı doğrudan bizim sunucumuza bildirir; uygulama "izledim" diye yalan söyleyemez. |
| Moderasyon | **OpenAI omni-moderation** (ücretsiz, görsel+metin) + kendi kurallarımız + şikayet sistemi | Ücretsiz ve görsel destekli. Yedek: AWS Rekognition / Google Vision (ücretli). |
| Hata takibi | Sentry (ücretsiz katman) | Çökme raporları. |
| Diller | i18next + expo-localization | TR/EN, cihaz diline göre başlangıç. |

**Expo + Supabase önerini onaylıyorum**, daha iyi bir seçenek görmedim. Değerlendirdiğim alternatif:
- **Firebase:** Depoda boş bir `firestore.indexes.json` var, Firebase düşünülmüş olabilir. Firebase da iyi
  bir seçim ama (1) Firestore kuralları ilişkisel veride (oylar, engellemeler, tema sıralaması) RLS'ten daha
  zor ve hataya açık, (2) geri dönüş analizi için ayrıca BigQuery gerekir, (3) Supabase'in sabit aylık
  fiyatı "beni borca sokacak açık olmasın" kuralı için daha öngörülebilir. Bu yüzden Supabase.

**Depodaki mevcut dosyalar:** `app.json`, `babel.config.js`, `eas.json`, `firestore.indexes.json`,
`metro.config.js`, `package.json`, `tsconfig.json` — hepsi **boş (0 bayt)**. Aşama 1'de doldurulacak;
`firestore.indexes.json` Firebase kullanmadığımız için silinecek.

**Expo sürümü:** Aramalarda en güncel kararlı sürüm SDK 57 (React Native 0.86) görünüyor, SDK 58 belgeleri de
yayında. Aşama 1'de `create-expo-app` ile o gün en güncel kararlı sürümü kuracağım ve CLAUDE.md'ye yazacağım.

**Önemli kısıt:** Paylaş menüsü (share extension) ve AdMob yerel modül gerektirir, **Expo Go uygulamasında çalışmaz**.
Telefonunda test için "geliştirme derlemesi" (development build: Expo Go yerine sadece bizim uygulamamıza özel
test uygulaması) kuracağız. Android'de bu bir APK dosyası, iPhone'da Apple geliştirici hesabı gerektirir.

## 2. Genel yapı

```
┌──────────────────── Telefon (Expo uygulaması) ────────────────────┐
│ Ekranlar · i18n · yerel önbellek · AdMob SDK · paylaş menüsü       │
│ (hiçbir API anahtarı yok; sadece Supabase "anon" anahtarı — bu    │
│  anahtar herkese açık olacak şekilde tasarlanmıştır, RLS korur)   │
└───────────┬──────────────────────────────┬────────────────────────┘
            │ (kullanıcı oturumu / JWT)    │
   ┌────────▼─────────┐          ┌─────────▼──────────┐
   │ Postgres + RLS   │◄────────►│ Edge Functions     │──► AI sağlayıcı (FASHN / Gemini …)
   │ (Supabase)       │          │ (gizli anahtarlar) │──► OpenAI moderasyon
   └────────┬─────────┘          └─────────┬──────────┘──► Google Safe Browsing
            │                              │◄── AdMob SSV geri çağrısı
   ┌────────▼─────────┐                    │──► Expo Push
   │ Storage (özel    │◄───────────────────┘
   │ kovalar + RLS)   │
   └──────────────────┘
```

JWT: kullanıcının giriş yaptığını kanıtlayan, imzalı, kısa ömürlü dijital bilet.

Bölge: Supabase projesi **AB (Frankfurt, eu-central-1)** — GDPR için AB içinde, Türkiye'ye yakın, hızlı.

## 3. Veri modeli

Tüm tablolar `public` şemasında, hepsinde RLS **açık**. `uid` = giriş yapmış kullanıcının kimliği (`auth.uid()`).
Silme: kullanıcıya bağlı her tablo `on delete cascade` ile `profiles`'a bağlı; hesap silinince her şey gider.

### 3.1 Kullanıcı

| Tablo | Alanlar (özet) |
|---|---|
| `profiles` | `id` (= auth kullanıcı id), `username` (benzersiz), `display_name`, `avatar_path`, `birth_date`, `adult_confirmed_at`, `country` (ISO, ör. TR), `locale` (tr/en), `currency` (TRY/USD/EUR…), `size_system` (EU/US/UK), `role` (user/moderator/admin), `status` (active/suspended/deleting), `allow_try_on_my_posts` (bool), `notif_prefs` (jsonb), `streak_current`, `streak_best`, `streak_last_day`, `created_at` |
| `consents` | `user_id`, `type` (terms, privacy, body_photo_processing, cross_border_transfer, skin_tone, marketing), `version`, `granted_at`, `revoked_at` — rıza geçmişi silinmez, değişmez (sadece yeni satır) |
| `digital_twins` | `user_id` (PK), `photo_path` (özel kova), `photo_version` (int), `photo_sha256`, `height_cm`, `size_top`, `size_bottom`, `shoe_size`, `skin_tone` (null olabilir), `style_prefs` (text[]), `moderation_status`, `changes_this_month`, `updated_at` |
| `push_tokens` | `user_id`, `token`, `platform`, `updated_at` |
| `blocks` | `blocker_id`, `blocked_id`, `created_at` (PK ikisi birlikte) |

### 3.2 Deneme ve haklar

| Tablo | Alanlar |
|---|---|
| `credit_state` | `user_id` (PK), `day` (Türkiye tarihi), `free_used` (0–3), `ad_earned_today`, `ad_balance` — her işlemde satır kilitlenir (aynı anda iki istek iki kez harcayamaz) |
| `credit_ledger` | `id`, `user_id`, `delta` (+1/-1), `reason` (free_spend, ad_reward, ad_spend, refund, admin_grant), `ref_id`, `created_at` — **değişmez muhasebe defteri**; `unique(reason, ref_id)` ile aynı olay iki kez yazılamaz |
| `ad_rewards` | `transaction_id` (AdMob'dan, benzersiz), `user_id`, `ad_unit`, `reward_amount`, `verified_at` |
| `try_on_jobs` | `id`, `user_id`, `source` (upload/share/post), `source_post_id`, `garment_path`, `garment_sha256`, `category`, `twin_version`, `provider`, `provider_model`, `provider_job_id`, `cache_key`, `status` (queued/running/succeeded/failed/blocked), `result_path`, `result_sha256`, `est_cost_usd`, `error_code`, `charged` (bool), `refunded` (bool), `created_at`, `finished_at` |
| `provider_spend_daily` | `day`, `provider`, `calls`, `est_cost_usd` — günlük bütçe sigortası için |

`cache_key` = sha256(ikiz fotoğraf hash + kıyafet hash + kategori + sağlayıcı + model + parametreler).
Aynı anahtarla başarılı bir sonuç varsa yeni AI çağrısı yapılmaz, hak düşmez.

### 3.3 İçerik

| Tablo | Alanlar |
|---|---|
| `posts` | `id`, `user_id`, `kind` (**worn** = Giyildi / **tryon** = Deneme), `image_path`, `image_sha256`, `try_on_job_id` (kind=tryon ise zorunlu), `caption`, `theme_id` (null olabilir), `allow_try_on`, `status` (pending/visible/hidden/removed), `report_count`, `created_at`, `deleted_at` |
| `post_items` | `id`, `post_id`, `position`, `label`, `url`, `merchant_domain`, `price_amount`, `price_currency`, `safe_check_at` |
| `themes` | `id`, `day` (benzersiz), `title_tr`, `title_en`, `description_tr/en`, `status` (scheduled/open/voting/closed) |
| `theme_results` | `theme_id`, `post_id`, `rank`, `score`, `wins`, `appearances` |
| `vote_pairs` | `id`, `voter_id`, `post_a`, `post_b`, `theme_id`, `issued_at`, `expires_at`, `voted_at` — çifti **sunucu verir** |
| `votes` | `id`, `pair_id` (benzersiz), `voter_id`, `winner_post_id`, `loser_post_id`, `theme_id`, `created_at` |
| `reports` | `id`, `reporter_id`, `target_type` (post/user/item), `target_id`, `reason`, `details`, `status` (open/actioned/dismissed), `handled_by`, `handled_at` |
| `moderation_events` | `id`, `target_type`, `target_id`, `provider`, `flagged` (bool), `categories` (jsonb), `decision`, `created_at` |

**Etiket dürüstlüğü kuralları (veritabanı kısıtı olarak):**
- `kind = 'tryon'` ise `try_on_job_id` dolu olmalı, o iş **kullanıcının kendisine** ait ve `succeeded` olmalı.
- `kind = 'worn'` ise yüklenen görselin hash'i sistemdeki hiçbir deneme sonucunun hash'iyle eşleşmemeli
  (kendi AI sonucunu "Giyildi" diye paylaşamaz). Not: başka AI araçlarıyla üretilmiş görseli kesin tespit edemeyiz; bunun için "yanlış etiket" şikayeti var.

### 3.4 Satış ortaklığı

| Tablo | Alanlar |
|---|---|
| `affiliate_rules` | `id`, `merchant_domain` (ör. amazon.com.tr), `country` (TR / * global), `program`, `rewrite_type` (query_param / template / network_deeplink), `rewrite_value`, `active` — anahtarlar/etiket kimlikleri burada değil, sunucu ortam değişkeninde |
| `link_clicks` | `id`, `post_item_id`, `user_id`, `country`, `program`, `created_at` (dönüştürülmüş tam URL saklanmaz) |

### 3.5 Ölçüm ve sistem

| Tablo | Alanlar |
|---|---|
| `events` | `id`, `user_id`, `name`, `props` (jsonb, kişisel veri yok), `platform`, `app_version`, `created_at` |
| `system_settings` | `key`, `value` — `daily_free_tries=3`, `max_ad_rewards_per_day=2`, `global_daily_budget_usd`, `per_user_daily_hard_cap=6`, `active_provider`, `tryon_enabled` |

Kaydedilen olaylar: `signup_completed`, `twin_created`, `tryon_requested`, `tryon_succeeded`, `tryon_failed`,
`tryon_cache_hit`, `ad_reward_granted`, `vote_cast`, `post_created`, `theme_entry`, `share_exported`,
`link_clicked`, `report_created`, `app_opened`.

Geri dönüş paneli: `app_opened` olaylarından SQL görünümleri — kayıt günü kohortu, 1/7/30. günde geri gelen
yüzde. Panel uygulama içi yönetici sekmesinde (PRD §6.15).

## 4. Depolama (Storage)

| Kova | Erişim | İçerik |
|---|---|---|
| `bodies` | **Özel.** Sadece sahibi okur/yazar (`{uid}/...` yolu). Sunucu fonksiyonu AI'a göndermek için okur. | Dijital ikiz fotoğrafı |
| `garments` | Özel, sadece sahibi | Denemek için yüklenen kıyafet görselleri |
| `tryon-results` | Özel, sadece sahibi | AI sonuçları |
| `posts` | Giriş yapmış kullanıcılar, sadece gönderi `visible` ise ve engelleme yoksa (RLS `posts` tablosuna bakar) | Paylaşılan gönderi görselleri (deneme paylaşılırken sonuç buraya **kopyalanır**; orijinal özel kalır) |
| `avatars` | Giriş yapmış kullanıcılar okur, sahibi yazar | Profil fotoğrafları |

- Uygulama görselleri **kısa ömürlü imzalı linklerle** (ör. 1 saat geçerli) görür; kalıcı açık link yok.
- Yüklemeden önce uygulama görseli küçültür (en uzun kenar 1536 px, JPEG %85) — depolama ve AI maliyeti için.
- EXIF/konum bilgisi yüklemeden önce silinir.

## 5. Satır bazlı yetki (RLS) kuralları — eksiksiz liste

Genel ilke: **varsayılan yasak.** Her tabloda sadece aşağıda yazılan izinler var. Kritik yazma işlemleri
(hak düşme, oy, deneme, ödül) doğrudan tabloya değil, **sunucu fonksiyonu veya güvenli veritabanı
fonksiyonu (security definer RPC)** üzerinden yapılır; istemcinin bu tablolara doğrudan yazma izni yoktur.

| Tablo | Okuma | Ekleme | Güncelleme | Silme |
|---|---|---|---|---|
| `profiles` | Herkes (giriş yapmış): sadece herkese açık alanlar `public_profiles` görünümüyle; tam satır sadece sahibi | Kayıt tetikleyicisi | Sahibi; ama `role`, `status`, `streak_*`, `adult_confirmed_at` değiştiremez (sütun kısıtı) | Sadece hesap silme fonksiyonu |
| `consents` | Sahibi | Sahibi (sadece kendi adına) | Yok | Yok (hesap silmeyle gider) |
| `digital_twins` | **Sadece sahibi** | Sahibi | Sahibi (ayda 5 değişiklik sınırı tetikleyicide) | Sahibi |
| `credit_state`, `credit_ledger` | Sahibi | **Yok** (sadece sunucu) | **Yok** | Yok |
| `ad_rewards` | Sahibi | Yok (sadece SSV fonksiyonu) | Yok | Yok |
| `try_on_jobs` | Sahibi | Yok (sadece `tryon-create`) | Yok | Sahibi (kendi geçmişini silebilir) |
| `posts` | `visible` olanlar, engelleme yoksa; sahibi kendi tüm gönderilerini | Sahibi, `create_post` RPC ile (etiket kuralları + moderasyon) | Sahibi sadece `caption`, `allow_try_on` | Sahibi |
| `post_items` | Bağlı gönderiyi görebilen | Gönderi sahibi | Gönderi sahibi | Gönderi sahibi |
| `themes`, `theme_results` | Herkes | Admin | Admin | Admin |
| `vote_pairs` | Sahibi | Yok (`next_pairs` RPC) | Yok | Yok |
| `votes` | Sahibi | Yok (`cast_vote` RPC: çift kendisine verilmiş, süresi geçmemiş, oylanmamış olmalı) | Yok | Yok |
| `reports` | Raporlayan kendi raporunu; moderator/admin hepsini | Giriş yapmış herkes (günde 30 sınır) | Moderator/admin | Yok |
| `blocks` | Sahibi (blocker) | Sahibi | Yok | Sahibi |
| `link_clicks`, `events` | Admin | Sahibi (sadece kendi `user_id`'siyle, `events` için) / sunucu | Yok | Yok |
| `affiliate_rules`, `system_settings`, `provider_spend_daily`, `moderation_events` | Admin | Admin / sunucu | Admin | Admin |

Engelleme kuralı tüm içerik okumalarında iki yönlü uygulanır (`not exists (select 1 from blocks …)`).
Askıya alınmış kullanıcının içeriği görünmez.

Her kural için otomatik test yazılacak (pgTAP: Postgres içinde test yazma aracı). Örn. "A kullanıcısı B'nin
ikiz fotoğrafını okuyamaz", "kullanıcı credit_state'e doğrudan yazamaz".

## 6. Sanal deneme — sağlayıcı karşılaştırması

**Yöntem ve dürüstlük notu:** Araştırma 11 Kasım 2026'da web aramasıyla yapıldı. Bu oturumun ağ kısıtı nedeniyle
sağlayıcıların resmi fiyat sayfalarını doğrudan açamadım; rakamlar arama sonuçlarındaki resmi doküman
alıntılarından ve üçüncü taraf fiyat izleyicilerden. **Para yatırmadan önce resmi sayfadan teyit edilecek.**

| Sağlayıcı / model | Tür | Deneme başı fiyat | Hız | Kalite (bulgular) | Gizlilik | Risk |
|---|---|---|---|---|---|---|
| **FASHN Try-On v1.6** | Denemeye özel | 1 kredi = **0,075 $** (taahhütle 0,049 $'a iner) | 5–8 sn (resmi doküman) | Bağımsız testte "sadece kıyafet değişsin" işinde en sadık sonuç; desen kaybı örnekleri var | Veri eğitimde kullanılmıyor; base64 girdiler saklanmıyor, çıktılar 72 saatte siliniyor | Küçük şirket; başarısız istek ücretsiz |
| **FASHN Try-On Max** | Denemeye özel, yüksek kalite | 2–5 kredi = **0,15–0,375 $** | daha yavaş | Daha yüksek çözünürlük/kalite | Aynı | Pahalı; MVP'de değil, ileride premium |
| **Google Nano Banana 2.1** (Gemini görsel modeli) | Genel görsel düzenleme | 1K: **~0,034 $** (yeni fiyat, teyit edilmeli); önceki sürüm 0,067 $ | ~10–20 sn (ölçülecek) | Kimlik korumada akademik testte yüksek puan; ama kıyafeti "yorumlayabiliyor" (bol/kısa yapma), poz/arka plan kayması | Ücretli katmanda veri eğitimde kullanılmaz (teyit edilecek) | Sürümler hızlı değişiyor/emekliye ayrılıyor |
| **Google Vertex AI Virtual Try-On (virtual-try-on-001)** | Denemeye özel | **~0,06 $** (üçüncü taraf) | — | Google'ın mağaza denemesi teknolojisi | Google Cloud şartları | Takip sitelerinde 15 Mart 2027 emeklilik tarihi görünüyor → **önerilmez** |
| **OpenAI gpt-image-1.5** | Genel görsel düzenleme | Orta kalite 1024²: **0,034 $** (resmi model sayfası) | ~15–30 sn | Kimlik tutarlılığı Nano Banana Pro'nun gerisinde | OpenAI API şartları | Gerçek kişi düzenlemede içerik politikası reddi riski |
| ~~Kling Kolors Virtual Try-On~~ | Denemeye özel | 0,07 $ | — | — | — | **15 Eylül 2026'da emekliye ayrıldı** — elendi |

**Önerim:**
1. **Ana sağlayıcı: FASHN Try-On v1.6** — denemeye özel, hızlı, başarısız isteği ücretlendirmiyor, gizlilik
   şartları bizim kurallarımıza en uygun (girdiyi base64 göndereceğiz → saklanmıyor).
2. **Yedek / ucuz kanal: Google Nano Banana 2.1** — FASHN çökerse otomatik devreye girer; ayrıca reklamla kazanılan
   haklar için ucuz kanal olabilir (Açık Soru 3c).
3. **Karar öncesi kör test (Aşama 4):** 20 farklı vücut fotoğrafı × kıyafet (düz ürün fotoğrafı, manken üstü,
   ekran görüntüsü, akıştaki başkasının kombini) ile iki sağlayıcıyı çalıştıracağım; sen hangisinin hangi sağlayıcı
   olduğunu bilmeden puanlayacaksın. Toplam maliyet ~5 $.

**Bilinen zorluk:** "Bende Dene" ile başka birinin üstündeki **tam kombini** (üst+alt) aktarmak, tek parça aktarmaktan
zordur; FASHN'da iki ardışık çağrı (2 hak değil, 1 hak — maliyeti biz üstleniriz) gerekebilir. Kör testte ölçülecek.

### 6.1 Soyutlama katmanı (sağlayıcıyı değiştirilebilir kılmak)

Tüm sağlayıcılar `supabase/functions/_shared/tryon/` altında tek bir arayüzü uygular:

```ts
interface TryOnProvider {
  id: 'fashn' | 'gemini' | 'mock' | string;
  estimateCostUsd(req: TryOnRequest): number;
  submit(req: TryOnRequest): Promise<{ providerJobId: string }>;
  poll(providerJobId: string): Promise<TryOnStatus>; // running | succeeded(imageBytes) | failed(code, retryable)
}
interface TryOnRequest {
  personImage: Uint8Array;   // ikiz fotoğrafı (base64'e çevrilip gönderilir, URL değil)
  garmentImage: Uint8Array;
  category: 'top' | 'bottom' | 'one_piece' | 'auto';
  garmentPhotoType: 'flat_lay' | 'on_model' | 'auto';
  seed?: number;
}
```

- Aktif sağlayıcı `system_settings.active_provider` ile seçilir; kod değişmeden değiştirilebilir.
- **`mock` sağlayıcı** test ve geliştirme içindir: AI çağırmaz, sabit bir örnek görsel döndürür. Geliştirme
  sırasında mock kullandığımda bunu sana açıkça söyleyeceğim.
- Hata çeviricisi: her sağlayıcının hata kodları ortak kodlara çevrilir (`INVALID_PERSON`, `INVALID_GARMENT`, `NSFW`, `TIMEOUT`, `PROVIDER_DOWN`).

### 6.2 Deneme akışı (sunucuda)

`tryon-create` fonksiyonu sırasıyla:
1. Oturum doğrula; hesap aktif, 18+ onaylı, `body_photo_processing` ve `cross_border_transfer` rızası var mı?
2. Hız sınırı: kullanıcı başı dakikada 3 istek; aynı anda en fazla 1 çalışan iş.
3. Kıyafet görselini oku (yükleme / paylaşım / gönderi). Gönderiyse: görünür mü, `allow_try_on` açık mı, engelleme yok mu?
4. **Önbellek:** `cache_key` ile başarılı sonuç varsa → hak düşmeden döndür (`tryon_cache_hit`).
5. **Kıyafet moderasyonu** (ücretsiz): çıplaklık / yasak kategori (iç çamaşırı, mayo) → reddet, hak düşmez.
6. **Bütçe sigortası:** bugünkü toplam tahmini harcama + bu istek > `global_daily_budget_usd` ise deneme geçici
   kapatılır ("Bugün yoğunluk var, haklarını yarın kullanabilirsin"), sana e-posta/bildirim gider.
7. **Hak düş (atomik):** `consume_credit(uid, job_id)` veritabanı fonksiyonu satırı kilitler; önce ücretsiz hak,
   sonra reklam hakkı. Kullanıcı başı günlük mutlak üst sınır (`per_user_daily_hard_cap`, öneri 6) aşılamaz.
8. Sağlayıcıya gönder → `try_on_jobs.status = running`.
9. Uygulama 2 sn arayla `tryon-status` sorar; bu fonksiyon sağlayıcıyı yoklar. Bitince sonuç `tryon-results`
   kovasına yazılır, **çıktı moderasyonu** yapılır, `succeeded`.
10. **Hata / zaman aşımı (90 sn) / çıktı moderasyonu reddi → hak otomatik iade** (`refund`, defterde tek kez).
11. Uygulama kapanırsa: pg_cron her dakika takılı işleri tarar, bitirir veya iade eder.

Böylece: istemci hak sayısını değiştiremez, aynı hakkı iki kez harcayamaz, sınırsız istek atamaz, tek kullanıcı
günde 6 denemeden (~0,45 $) fazlasına mal olamaz, tüm sistem günlük bütçeyi aşamaz.

## 7. Paylaş menüsünden görsel alma

- Expo'nun resmi `expo-sharing` paketi yeni sürümlerde **gelen paylaşımı** (`useIncomingShare`) destekliyor
  (SDK 57/58 belgeleri). Yedek: topluluk paketi `expo-share-intent`.
- iOS notu (Expo belgesi): paylaşım uzantısı ana uygulamayı açarak çalışıyor; Apple bunu resmi olarak desteklemiyor,
  ileride bir iOS sürümünde bozulabilir. Bozulursa yerel bir "paylaşım görünümü" yazmamız gerekir — risk olarak not edildi.
- Sadece görsel kabul edilir (en fazla 1 görsel). Link paylaşılırsa: "Lütfen ürün görselini paylaş" uyarısı (link
  içinden görsel çekmek MVP dışı).

## 8. Satış ortaklığı katmanı

- Uygulama ürün linkini asla doğrudan açmaz; `go?item={id}` sunucu fonksiyonuna gider.
- Fonksiyon: tıklamayı `link_clicks`'e yazar → kullanıcının ülkesi (profil, yoksa istek başlığı) + mağaza alan
  adına göre `affiliate_rules`'tan kural bulur → URL'yi dönüştürür → 302 ile yönlendirir. Kural yoksa orijinal link.
- Kural türleri: sorgu parametresi ekleme (ör. Amazon `tag=`), şablon, ağ derin linki (Admitad, AWIN gibi
  ağlar tek linkle çok mağazayı kapsar).
- Program kimlikleri ortam değişkeninde (gizli), kurallar tabloda (yeni ülke/mağaza kod değişmeden eklenir).
- Link eklenirken Google Safe Browsing kontrolü; `http` değil sadece `https`; uygulama içi tarayıcıda açılır.
- Satış ortaklığı programlarının Türkiye'deki güncel koşullarını aramada net bulamadım — başvurular senin işin
  (BENIM_ISLERIM.md), entegrasyonu program onaylandıkça kural satırı ekleyerek yapacağım. **İlk sürümde hiçbir
  program onaylı değilse linkler dönüştürülmeden açılır, sadece tıklama ölçülür.**

## 9. Gizlilik, KVKK ve GDPR

**Ben avukat değilim.** Aşağıdakiler teknik tasarımdır; metinlerin hukukçu tarafından kontrol edilmesini öneriyorum.

- **Veri minimizasyonu:** Doğum tarihi sadece 18+ kontrolü için; ten tonu isteğe bağlı; konum toplanmaz; EXIF silinir.
- **Ayrı açık rızalar** (her biri ayrı onay kutusu, varsayılan boş, geri çekilebilir, sürümlü kayıt):
  vücut fotoğrafının işlenmesi, yurt dışına aktarım (AI sağlayıcısı ABD/AB), ten tonu (özel nitelikli olabilir), pazarlama.
- **Yurt dışı aktarım:** KVKK'nın 2024 değişikliğiyle yurt dışı aktarım için standart sözleşme imzalanıp
  KVKK'ya 5 iş günü içinde bildirilmesi gerekiyor (avukata teyit ettirilecek). Supabase (AB), FASHN, Google, OpenAI ile.
- **Saklama:** İkiz fotoğrafı kullanıcı silene kadar; deneme sonuçları kullanıcı silene kadar (veya 12 ay
  etkinlik yoksa — öneri); olay kayıtları 24 ay sonra anonimleştirilir; silinen hesap 30 gün içinde yedeklerden çıkar.
- **Sağlayıcıya gönderim:** Görseller URL olarak değil base64 olarak gönderilir (FASHN bunları saklamıyor);
  sağlayıcının eğitim için veri kullanmadığı plan/ayar seçilir.
- **Haklar:** Verilerimi indir (JSON + görseller, e-postayla link), hesabı sil, rızayı geri çek.
- **Kendi fotoğrafı kuralı:** beyan kutusu + moderasyon (tek kişi, reşit olmayan görünümlü kişi tespiti, çıplaklık)
  + "başkasının fotoğrafı" şikayet nedeni + ihlalde hesap askıya alma. Yüz eşleştirme MVP'de yok (Açık Soru 11).
- **AI etiketi:** Uygulama içinde rozet, dışa aktarımda filigran, dosya meta verisinde "AI generated" notu.

## 10. Güvenlik

- **API anahtarları** (FASHN, Gemini, OpenAI, Safe Browsing, AdMob SSV, satış ortaklığı) sadece Supabase
  "secrets" içinde. Uygulamada sadece Supabase URL'si ve **anon** anahtarı olur — bu anahtar tasarım gereği
  herkese açıktır, güvenliği RLS sağlar. `service_role` anahtarı asla uygulamaya girmez.
- **Ödüllü reklam:** Hak sadece AdMob'un sunucumuza gönderdiği, Google'ın açık anahtarıyla **imzası doğrulanan**
  geri çağrıyla verilir; `transaction_id` benzersiz (tekrar oynatma saldırısı olmaz); günlük sınır.
- **Kötüye kullanım:** hesap başı ve IP başı hız sınırları; yeni hesapların ilk 24 saatte günlük 1 deneme
  hakkı (çoklu hesap açarak bedava deneme toplamayı caydırır — **ürün kararı, onayına sunuyorum**).
- **Girdi doğrulama:** dosya türü (sadece JPEG/PNG/WebP/HEIC), boyut (≤ 10 MB), piksel sınırı, metin uzunlukları.
- **Bağımlılıklar:** Kilitli sürümler, düzenli güvenlik taraması.
- **Yönetici:** `role = admin` sadece veritabanından elle atanır; uygulamadan rol yükseltme yok.

## 11. Test stratejisi

| Katman | Araç | Ne test edilir |
|---|---|---|
| Veritabanı | pgTAP (`supabase test db`) | Her RLS kuralı, hak düşme/iade atomikliği, etiket kısıtları, oy kuralları |
| Sunucu fonksiyonları | Deno test | Deneme akışı (mock sağlayıcıyla), SSV imza doğrulama, link dönüştürme, bütçe sigortası |
| Uygulama | Jest + React Native Testing Library | Ekran mantığı, i18n anahtarlarının tamlığı, beden/para birimi dönüşümleri |
| Uçtan uca | Maestro (ileride) | Kayıt → ikiz → deneme → paylaş akışı |

## 12. MVP dışı özellikler için açık kapılar

| Gelecek özellik | Bugünden hazır olan |
|---|---|
| Premium abonelik | `credit_state` kural tabanlı; `system_settings` ile plan başı hak sayısı |
| Stil düellosu, zevk kaydırması | `vote_pairs`/`votes` genel yapı, `context` alanı eklenebilir |
| İstek listesi + fiyat bildirimi | `post_items` normalize, `merchant_domain` ayrı |
| Dolabım / ortak dolap / ikinci el | `garments` kovası + `try_on_jobs.garment_sha256` |
| Remix komisyonu | `link_clicks` gönderi sahibine bağlanabilir |
| Sponsorlu temalar | `themes` tablosuna `sponsor_id` eklenir |
| Şehir/kampüs katmanı | `profiles.country` yanında `region` alanı |
| Video üretimi | Sağlayıcı arayüzü `output: image | video` ile genişler |
| Marka veri paneli | `events` + anonim agregasyon görünümleri |

## 13. Kaynaklar (araştırma)

- FASHN fiyat ve uç noktalar: [FASHN API](https://fashn.ai/products/api), [Try-On Max changelog](https://fashn.ai/changelog/api-try-on-max-endpoint-now-available), [Çözünürlük katmanları](https://fashn.ai/changelog/new-resolution-tiers-and-generation-mode-controls), [Veri saklama](https://docs.fashn.ai/api-overview/data-retention-privacy), [Genlook karşılaştırması](https://genlook.app/developers/vs/fashn), [v1.6 dokümanı](https://docs.fashn.ai/api-reference/tryon-v1-6)
- Google VTO: [Vertex AI virtual-try-on-001](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/imagen/virtual-try-on-001), [Maxim fiyat izleyici](https://www.getmaxim.ai/bifrost/model-library/compare/vertex_ai/virtual-try-on-001), [cloudprice](https://cloudprice.net/models/google-virtual-try-on-1)
- Gemini görsel: [BenchLM Nano Banana fiyatları](https://benchlm.ai/media-pricing/nano-banana), [Nano Banana 2.1 fiyat haberi](https://fourweekmba.com/ai-google-halves-nano-banana-image-price-triples-input-price/), [Gemini 3.1 Flash Image](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-1-flash-image)
- OpenAI: [GPT Image 1.5 model sayfası](https://developers.openai.com/api/docs/models/gpt-image-1.5), [Moderasyon](https://developers.openai.com/api/docs/guides/moderation)
- Kling: [Kling Virtual Try-On API (emeklilik notu)](https://kling.ai/document-api/api/image/virtual-try-on.md)
- Kalite karşılaştırmaları: [Fuser testi](https://fuser.studio/articles/best-ai-virtual-try-on), [ionio karşılaştırması](https://www.ionio.ai/blog/vton), [Oxygen-TryOn makalesi](https://arxiv.org/html/2607.21694v1), [fal.ai liste](https://fal.ai/learn/tools/best-virtual-try-on-apis-2026)
- Expo paylaşım: [expo-sharing (latest)](https://docs.expo.dev/versions/latest/sdk/sharing.md), [expo-share-intent](https://npmjs.com/package/expo-share-intent), [Expo sürümleri](https://docs.expo.dev/versions/latest/)
- Mağaza kuralları: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [Google Play UGC](https://support.google.com/googleplay/android-developer/answer/9876937), [Google Play test şartı](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
