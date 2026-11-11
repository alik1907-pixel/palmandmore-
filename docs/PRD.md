# Kabin — Ürün Gereksinimleri (PRD)

> Durum: **Taslak v0.1 — onay bekliyor** · Tarih: 11 Kasım 2026
> "Kabin" çalışma adıdır. Mağaza adı ve marka tescili ayrıca kontrol edilecek.

## 1. Ürün tek cümlede

Kabin, gerçek insanların kombinlerini paylaştığı, oyladığı ve beğendiği
kombini yapay zekâ ile **kendi üstünde** görebildiği bir sosyal giyim uygulamasıdır.

## 2. Temel ilkeler

1. **İçerik insan, ayna AI.** Akıştaki her kombin gerçek bir kullanıcıya aittir.
   AI kombin uydurmaz; sadece var olan bir kıyafeti kullanıcının kendi fotoğrafına giydirir.
2. **Bedava eylem bol, AI kıt.** Kaydırma, oylama, gönderi paylaşma, tema yarışması
   sınırsız ve bedavadır. AI denemesi günlük kotalı bir ödüldür.
3. **Dürüst etiket.** Her gönderi ya **Giyildi** (gerçek fotoğraf) ya da **Deneme**
   (AI görseli) etiketi taşır. Etiket gizlenemez.
4. **Vücut fotoğrafı kutsaldır.** Dijital ikiz fotoğrafı sadece sahibine açıktır,
   asla akışta görünmez, asla başkası tarafından kullanılamaz.
5. **Kimse bizi borca sokamaz.** Her AI çağrısı sunucuda sayılır, sınırlanır, gerektiğinde iade edilir.

## 3. Hedef kullanıcı

- 18–34 yaş, Türkiye'de yaşayan, Instagram/TikTok'ta kombin içeriği tüketen,
  online alışverişte "üstümde nasıl durur?" kaygısı yaşayan kullanıcılar.
- İkincil: İngilizce konuşan global kullanıcılar (arayüz hazır, pazarlama sonra).

## 4. Başarı ölçütleri (MVP)

| Ölçüt | Hedef (ilk 3 ay) |
|---|---|
| 1. gün geri dönüş (D1) | ≥ %35 |
| 7. gün geri dönüş (D7) | ≥ %15 |
| 30. gün geri dönüş (D30) | ≥ %7 |
| Aktif gün başına oy | ≥ 20 |
| Aktif kullanıcı başına aylık deneme | 5–15 (maliyet bandı) |
| Ürün linki tıklama oranı (gönderi görüntülemesine göre) | ≥ %1 |

Bu hedefler sektör tahminidir, ölçtükçe güncellenecek.

## 5. MVP kapsamı (sadece bunlar)

| # | Özellik | Kısa tanım |
|---|---|---|
| 1 | Kayıt / giriş / 18+ / profil | E-posta, Apple ve Google ile giriş. Doğum tarihiyle 18+ onayı. |
| 2 | Dijital ikiz | Tam boy fotoğraf + boy, beden, (isteğe bağlı) ten tonu, stil tercihleri. |
| 3 | Sanal deneme | Kıyafet görseli / ekran görüntüsü yükle, paylaş menüsünden gönder veya akıştan "Bende Dene". |
| 4 | Akış | Kullanıcı kombinleri; Giyildi / Deneme etiketi zorunlu. |
| 5 | Günlük tema | Her gün tek tema, gönderim, ertesi gün sonuç. |
| 6 | "Hangisi?" | İki kombin yan yana, dokun-oy ver, sonsuz akış. |
| 7 | Ürün linkleri | Kombindeki parçalara link; ülkeye göre satış ortaklığı katmanı. |
| 8 | Deneme hakkı | Günde 3 ücretsiz, ödüllü reklamla +1 (günlük üst sınırlı). Sunucuda uygulanır. |
| 9 | Dışa aktarma | Filigranlı görsel kaydet / paylaş. |
| 10 | Seri + bildirim | Günlük seri sayacı, tema/sonuç/seri hatırlatma bildirimleri. |
| 11 | Güvenlik | Şikayet, engelle, moderasyon, hesap ve tüm veriyi silme. |
| 12 | Dil / bölge | Türkçe + İngilizce; ülkeye göre para birimi ve beden sistemi. |

**MVP'de bilinçli olarak YOK:** takip etme, beğeni, yorum, mesajlaşma (moderasyon yükünü
ve mağaza riskini düşürür — bkz. Açık Sorular). MVP dışı listesi (stil düellosu, premium,
dolabım vb.) için mimari kapılar açık bırakılır, bkz. MIMARI.md §12.

---

## 6. Ekran ekran kullanıcı akışları

Gösterim: `[Ekran]` → eylem → `[Sonraki ekran]`. Her ekran TR/EN çalışır.

### 6.1 İlk açılış ve kayıt

1. `[Karşılama]` — 3 kaydırmalı tanıtım kartı: "Gerçek kombinler", "Kendinde dene", "Her gün tema".
   Altta **Başla** ve **Zaten hesabım var**.
2. `[Giriş yöntemi]` — "Apple ile devam et" (sadece iOS'ta), "Google ile devam et",
   "E-posta ile devam et" (sihirli link veya 6 haneli kod; şifre yok).
3. `[Doğum tarihi]` — tarih seçici. 18 yaşından küçükse: "Kabin 18 yaş ve üzeri içindir"
   ekranı, hesap oluşturulmaz, cihazda 24 saat tekrar denemesi engellenir (kolay yeniden
   deneme caydırılır; kesin doğrulama değildir, beyana dayanır).
4. `[Sözleşmeler]` — Kullanım Koşulları, Gizlilik Politikası, KVKK Aydınlatma Metni linkleri.
   Zorunlu tek onay: "Koşulları okudum ve kabul ediyorum". Pazarlama izni ayrı ve isteğe bağlı.
5. `[Profil kur]` — kullanıcı adı (benzersiz, küçük harf, 3–20 karakter), görünen ad,
   isteğe bağlı profil fotoğrafı, ülke (cihazdan önerilir), dil.
6. `[Bildirim izni ön ekranı]` — neden bildirim istediğimizi anlatan ekran, sonra sistem izni.
7. → `[Ana sekme: Akış]`. Dijital ikiz zorunlu değil; ilk "Dene" denemesinde istenir.

### 6.2 Ana gezinme (alt sekme çubuğu)

`Akış` · `Hangisi?` · `(+) Ekle` · `Tema` · `Profil`

- `(+)` alttan bir menü açar: **Kombin paylaş** · **Kıyafet dene**.
- Sağ üstte her zaman **deneme hakkı rozeti** (ör. "2/3") görünür.

### 6.3 Dijital ikiz kurulumu

1. `[İkiz tanıtım]` — "Fotoğrafın sadece sana görünür, akışta asla yayınlanmaz" vurgusu.
2. `[Açık rıza]` — ayrı açık rıza ekranı: vücut fotoğrafının AI sağlayıcısına (yurt dışı)
   işlenmek üzere gönderilmesi. Onay kutusu varsayılan **boş**. Rıza vermeyen kullanıcı
   denemeyi kullanamaz ama uygulamanın geri kalanını kullanır.
3. `[Fotoğraf rehberi]` — iyi/kötü örnekler: tam boy, önden, sade arka plan, tek kişi,
   dar/normal kıyafet, iyi ışık. "Sadece kendi fotoğrafını yükle" beyanı (onay kutusu).
4. `[Fotoğraf çek / seç]` → `[Kırp ve önizle]`.
5. Sunucu kontrolü (birkaç saniye): tek kişi mi, uygunsuz içerik var mı, çok düşük
   çözünürlük mü. Red olursa sade bir neden gösterilir ("Fotoğrafta birden fazla kişi var").
6. `[Ölçüler]` — boy (cm/ft-in, ülkeye göre), üst beden, alt beden, ayakkabı numarası
   (beden sistemi ülkeye göre: TR/EU, US, UK), **isteğe bağlı** ten tonu, stil tercihleri
   (çoklu seçim: sade, sokak, klasik, spor, bohem, vb.).
7. `[İkiz hazır]` → kullanıcıyı geldiği yere (genelde denemeye) döndürür.
- Profil > Dijital ikiz'den fotoğraf değiştirilebilir (ayda en fazla 5 değişiklik — kötüye kullanım ve maliyet için) ve tamamen silinebilir.

### 6.4 Sanal deneme

Üç giriş noktası, tek sonuç ekranı:

- **A. Yükle:** `(+) > Kıyafet dene` → `[Görsel seç]` (galeri veya kamera; ekran görüntüsü de olur).
- **B. Paylaş menüsü:** Başka bir uygulamada (Instagram, Trendyol, tarayıcı) görsel →
  Paylaş → **Kabin** → uygulama açılır, görsel `[Deneme hazırlık]` ekranına gelir.
- **C. Bende Dene:** Akışta/Hangisi'nde bir gönderide **Bende Dene** düğmesi.

Akış:
1. `[Deneme hazırlık]` — kıyafet görseli önizleme + kategori seçimi (Üst / Alt / Elbise-tulum / Otomatik).
   Altta: "Bu deneme 1 hak kullanır. Kalan: 2". İkiz yoksa önce 6.3'e yönlenir.
2. **Dene** → sunucu: hak düşer, görsel kontrol edilir, AI çalışır.
3. `[Bekleme]` — 5–20 sn; eğlenceli animasyon + "Beklerken oy ver" kısayolu (Hangisi'ne gider,
   sonuç hazır olunca bildirim/rozet).
4. `[Sonuç]` — önce/sonra kaydırıcı. Görsel üzerinde her zaman küçük **"AI deneme"** rozeti.
   Düğmeler: **Kaydet/Paylaş (filigranlı)** · **Akışta paylaş (Deneme etiketiyle)** · **Tekrar dene** (yeni hak) · **Bildir** (kötü sonuç).
5. Hata olursa: "Bir sorun oldu, hakkın iade edildi" + tekrar dene.
- Haklar bittiyse: `[Hak bitti]` — "Yarın 00:00'da yenilenir" + **Reklam izle, +1 hak**
  (günlük reklam sınırına ulaşılmadıysa) + "Beklerken oy ver / tema gönderisi yap".
- Aynı ikiz fotoğrafı + aynı kıyafet görseli + aynı kategori tekrar denenirse önbellekteki sonuç
  **hak düşmeden** gösterilir.

Kategori kısıtı: **iç çamaşırı, mayo, bikini** denemeleri MVP'de kapalı (bkz. Açık Soru 5).

### 6.5 Akış

1. `[Akış]` — dikey kart listesi. İki sekme: **Yeni** ve **Bugünün teması**.
2. Kart: fotoğraf, etiket rozeti (**Giyildi** 📷 / **Deneme** ✨), kullanıcı adı, açıklama,
   parça sayısı ("3 parça" → dokununca linkler), **Bende Dene**, `···` menüsü (Şikayet et, Kullanıcıyı engelle, Gizle).
3. Karta dokun → `[Gönderi detay]`: büyük görsel, parça listesi (ad, mağaza alan adı, fiyat — varsa),
   **Satın al** (satış ortaklığı katmanından geçer, uygulama içi tarayıcıda açılır), sahibinin profiline geçiş.
4. Engellenen kullanıcıların içeriği hiçbir yerde görünmez (iki yönlü).

### 6.6 Kombin paylaşma

1. `(+) > Kombin paylaş` → kaynak seç: **Kendi fotoğrafım (Giyildi)** veya **Bir denemem (Deneme)**.
   - Giyildi: kamera/galeri. "Bu fotoğraf bana ait ve gerçekten giydim" beyanı.
   - Deneme: sadece kullanıcının kendi başarılı deneme sonuçlarından seçilir (etiket otomatik, değiştirilemez).
2. `[Düzenle]` — kırp, açıklama (en fazla 300 karakter), isteğe bağlı **Bugünün temasına gönder**.
3. `[Parçalar]` — isteğe bağlı: parça adı + ürün linki + fiyat/para birimi (opsiyonel). En fazla 8 parça.
4. **Paylaş** → otomatik moderasyon (birkaç saniye) → yayında. Şüpheli içerik "inceleniyor" olarak bekler.
5. Ayar: "Başkaları bu kombini Bende Dene ile kullanabilir" (varsayılan açık).

### 6.7 Günlük tema

1. `[Tema]` sekmesi üstte: **Bugünün teması** (ör. "Yağmurlu pazartesi"), kalan süre, gönderi sayısı, **Gönder**.
2. Altında: **Dünün sonuçları** — ilk 3 kombin (kürsü görünümü), kullanıcının kendi sıralaması ("İlk %20'desin").
3. Gün sınırı ve takvim (öneri, bkz. Açık Soru 7):
   - Tema her gün 00:00'da (Türkiye saati) açılır, 23:59'da gönderime kapanır.
   - Oylama ertesi gün 20:00'ye kadar sürer (Hangisi? üzerinden).
   - Sonuçlar ertesi gün 20:00'de açıklanır, katılımcılara bildirim gider.
4. Kişi başı günlük temaya **1 gönderi**. Temalar önceden yönetici panelinden girilir (en az 30 günlük stok).

### 6.8 "Hangisi?" oylaması

1. `[Hangisi?]` — ekranda iki kombin yan yana (dikey ekranda üst/alt). Üstte bağlam: "Tema: Yağmurlu pazartesi" veya "Genel".
2. Birine dokun → seçilen kısa animasyon, oran gösterimi ("%64 seninle aynı") → 300 ms sonra yeni çift. Sonsuz.
3. "Atla" düğmesi. Uzun basınca: gönderi detay, Bende Dene, Şikayet.
4. Çiftleri sunucu üretir; kullanıcı kendi gönderisine, engellediği kişilere, aynı çifte ikinci kez oy veremez.
5. Karışım: tema açıksa çiftlerin ~%70'i tema gönderilerinden, kalanı genel akıştan.

### 6.9 Ürün linkleri ve satış ortaklığı

1. Kullanıcı herhangi bir `https` ürün linki ekler. Uygulama mağaza alan adını gösterir.
2. Linke tıklandığında istek sunucudaki yönlendiriciye gider: tıklama kaydedilir, kullanıcının
   ülkesine göre mağazanın satış ortaklığı kuralı varsa link dönüştürülür, yoksa link olduğu gibi açılır.
3. Gönderi detayında küçük açıklama: "Bazı bağlantılar satış ortaklığı içerir; satın alırsan Kabin komisyon alabilir."
4. Zararlı link koruması: linkler Google Safe Browsing ile kontrol edilir; zararlıysa eklenemez.

### 6.10 Deneme hakkı ve ödüllü reklam

- Günlük 3 ücretsiz hak (gece 00:00'da yenilenir, devretmez).
- Ödüllü reklam: izlenip reklam ağı **sunucumuza** "izlendi" bildirdiğinde +1 hak. Günde en fazla N
  reklam hakkı (öneri N=2, bkz. Açık Soru 3 — maliyet nedeni MALIYET.md'de).
- Reklamla kazanılan hak gün sonunda silinir.
- Başarısız denemede hak otomatik iade edilir.

### 6.11 Dışa aktarma

- Sonuç ekranında **Kaydet** ve **Paylaş**: görselin sağ altına "Kabin · AI deneme" filigranı basılır.
- "Giyildi" gönderiler dışa aktarılırken de küçük "Kabin" logosu eklenir.
- Not: ekran görüntüsü engellenemez; filigran caydırıcıdır, garanti değildir.

### 6.12 Seri ve bildirimler

- **Seri:** O gün en az 1 tema gönderisi **veya** 10 oy yapan kullanıcının serisi 1 artar (öneri, Açık Soru 8).
  Bir gün kaçırılırsa sıfırlanır. Profilde ve Tema sekmesinde alev simgesiyle görünür.
- **Bildirimler** (her biri ayarlardan kapatılabilir, günde en fazla 2):
  - 10:00 "Bugünün teması: …"
  - 20:00 "Dünün sonuçları açıklandı" (sadece katılanlara)
  - 21:30 "Serin bitmek üzere" (sadece serisi olan ve bugün aktif olmayanlara)
  - Deneme sonucu hazır (uygulama arka plandaysa)

### 6.13 Profil ve ayarlar

- `[Profil]` — avatar, kullanıcı adı, seri, gönderiler (Giyildi/Deneme filtreli), "Denemelerim" (sadece bana görünür).
- `[Ayarlar]` — dil, ülke, para birimi, beden sistemi, bildirimler, dijital ikiz, engellenenler,
  rızalarım (geri çekilebilir), verilerimi indir, **hesabımı sil**, yardım/iletişim, yasal metinler.
- **Hesabı sil:** iki adımlı onay → tüm fotoğraflar, gönderiler, denemeler, oylar, linkler,
  olay kayıtları kalıcı silinir (en geç 30 gün içinde yedeklerden de çıkar). Apple'ın uygulama
  içi hesap silme kuralına uygundur.

### 6.14 Şikayet, engelleme, moderasyon

- Her gönderi ve profilde **Şikayet et**: nedenler — çıplaklık/cinsel içerik, başkasının fotoğrafı,
  reşit olmayan kişi, nefret/taciz, yanlış etiket (AI ama "Giyildi"), spam/zararlı link, diğer.
- Şikayet eden kullanıcı o içeriği hemen bir daha görmez.
- 3 farklı kullanıcıdan şikayet alan içerik incelenene kadar otomatik gizlenir.
- **Engelle:** iki yönlü görünmezlik; engellenenin gönderisi Hangisi'nde de çıkmaz.
- Yönetici paneli: şikayet kuyruğu, içerik kaldırma, kullanıcı askıya alma, tema yönetimi.
  Hedef yanıt süresi: 24 saat (Apple bunu "zamanında" bekler).

### 6.15 Yönetici paneli (sadece yönetici hesabı)

Uygulama içinde gizli bir sekme (sadece `admin` rolündeki hesaba görünür):
- Ölçüm: günlük kayıt, deneme, oy, paylaşım, link tıklama; 1/7/30 gün geri dönüş tablosu.
- Maliyet: bugünkü AI harcaması / günlük bütçe sınırı.
- Moderasyon kuyruğu, tema takvimi, sistem ayarları (günlük hak sayısı, reklam sınırı, aktif AI sağlayıcısı).

---

## 7. Mağaza ve yasal gereklilikler (özet)

Ayrıntılar: MIMARI.md §9 ve YAPILACAKLAR.md "Yayın öncesi kontrol listesi".
- Kullanıcı içeriği: filtre, şikayet, engelleme, iletişim bilgisi (Apple 1.2, Google UGC politikası).
- Apple ile giriş (Google ile giriş sunduğumuz için iOS'ta zorunlu).
- Uygulama içi hesap silme.
- Yaş derecelendirmesi: 18+ (kullanıcı içeriği + yaş sınırı).
- Reklam: ödüllü reklam isteğe bağlıdır, zorla gösterilmez; çocuklara yönelik değil.
- AI içeriği açıkça etiketlenir.

## 8. Açık sorular (onayını bekleyenler)

Her soruda önerim **kalın**. Cevap verdiğinde bu bölümü "Kararlar" olarak güncelleyeceğim.

1. **Test telefonun iPhone mu Android mi?** iPhone ise Apple geliştirici hesabı (99 $/yıl) en baştan gerekir.
2. **Hesaplar şirket adına mı şahsın adına mı açılacak?** Şahıs Google Play hesabında "12 test kullanıcısı / 14 gün" kuralı var; şirket hesabı bundan muaf ama D-U-N-S numarası gerekir. **Öneri: şirketin varsa şirket adına.**
3. **Ödüllü reklam ekonomisi:** Bir ödüllü reklam Türkiye'de kabaca 0,2–0,8 sent kazandırırken bir deneme 3,4–7,5 sent tutuyor; yani "1 reklam = +1 hak" zarar ettirir. Seçenekler: (a) **günde en fazla 2 reklam hakkı, aradaki farkı pazarlama gideri say**, (b) 3 reklam = 1 hak, (c) reklamla kazanılan denemeler daha ucuz modelle üretilsin.
4. **AI sağlayıcısı:** **FASHN v1.6 ana sağlayıcı, Google Nano Banana yedek; karar vermeden önce 20 görsellik kör test yapalım** (sen puanlarsın). Bkz. MIMARI.md §6.
5. **İç çamaşırı / mayo / bikini denemeleri** — **MVP'de kapalı** (rıza dışı müstehcen görsel riski ve mağaza riski).
6. **Günlük temaya Deneme (AI) gönderileri girebilir mi?** **Öneri: sadece Giyildi** — yarışma adil olur, "içerik insan" ilkesi korunur.
7. **"Gün" nasıl hesaplansın?** **Öneri: tema, deneme hakkı ve seri için herkes Türkiye saati (00:00).** Global açılışta bölgesel temalar düşünülür.
8. **Seri neyle sayılsın?** **Öneri: günde 1 tema gönderisi VEYA 10 oy.**
9. **Takip / beğeni / yorum MVP'de olmasın** — onaylıyor musun? **Öneri: olmasın** (moderasyon yükü, kapsam).
10. **Başkasının gönderisinde "Bende Dene"** — **varsayılan açık, sahibi kapatabilir.**
11. **"Sadece kendi fotoğrafın" kuralı:** beyan + otomatik kontroller + şikayet yeterli mi, yoksa selfie ile yüz eşleştirme mi? Yüz eşleştirme biyometrik veridir (KVKK'da özel nitelikli), ek rıza ve maliyet getirir. **Öneri: MVP'de yüz eşleştirme yok.**
12. **Ten tonu alanı:** KVKK'da etnik köken verisi sayılabilir. **Öneri: isteğe bağlı + ayrı açık rıza**; deneme bu alanı kullanmıyor (fotoğraftan çalışıyor), ileride öneri sistemi için.
13. **Lansman pazarı:** **Önce Türkiye (TR+EN arayüz), global pazarlama sonra.**
14. **Şikayetleri ilk aşamada kim inceleyecek?** **Öneri: sen, yönetici panelinden; 3 şikayette otomatik gizleme.**
15. **Yeni hesaplara ilk 24 saat günde 1 deneme** (çoklu hesap açıp bedava hak toplamayı caydırmak için) — **öneri: evet.**
16. **Kaydedilmeyen deneme sonuçları 30 gün sonra silinsin** (kullanıcı "Kaydet" derse kalır) — **öneri: evet** (gizlilik + depolama maliyeti).
