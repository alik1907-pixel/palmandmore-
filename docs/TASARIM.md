# Kabin — Tasarım Sistemi

> Durum: **Taslak v0.1 — onay bekliyor** · Tarih: 11 Kasım 2026

## 1. Tasarım dili

**"Prova kabini"**: sade, sıcak, kumaş gibi yumuşak bir zemin; fotoğraflar kahraman. Arayüz geri planda
kalır, kombinler öne çıkar. İki etiketin (Giyildi / Deneme) rengi uygulamanın her yerinde sabittir ve hiçbir
yerde başka anlamda kullanılmaz — kullanıcı rengi görünce AI olup olmadığını anlar.

## 2. Renkler

Tüm renkler kodda **jeton** (token: tek bir yerde tanımlanıp her yerde adıyla kullanılan değer) olarak tanımlanır;
açık ve koyu tema desteklenir.

| Jeton | Açık tema | Koyu tema | Kullanım |
|---|---|---|---|
| `bg` | `#FAF7F2` (keten beyazı) | `#121110` | Sayfa zemini |
| `surface` | `#FFFFFF` | `#1C1A18` | Kartlar, alt sayfalar |
| `surfaceMuted` | `#F1ECE4` | `#262320` | Girdi alanları, pasif düğmeler |
| `ink` | `#161412` | `#F5F1EA` | Ana metin |
| `inkMuted` | `#6B645B` | `#A39B90` | İkincil metin |
| `border` | `#E4DDD2` | `#34302B` | Ayraçlar |
| `primary` | `#E2553F` (kabin perdesi kiremit) | `#F06A53` | Ana eylem düğmeleri, seçili sekme |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Ana düğme üzerindeki metin |
| `worn` | `#1E8A5A` (yeşil) | `#3FBF84` | **Giyildi** etiketi — sadece bu anlamda |
| `tryon` | `#6C4CF0` (mor) | `#9479FF` | **Deneme / AI** etiketi, deneme hakkı rozeti — sadece bu anlamda |
| `streak` | `#F59E0B` | `#FBBF24` | Seri alevi |
| `danger` | `#C62828` | `#EF5350` | Sil, şikayet onayı |
| `overlay` | `rgba(22,20,18,0.55)` | `rgba(0,0,0,0.6)` | Görsel üstü rozet zemini |

Erişilebilirlik: tüm metin/zemin çiftleri en az WCAG AA (4.5:1) kontrastta olacak; Aşama 1'de otomatik test
ile doğrulanacak, tutmayan ton koyulaştırılacak.

## 3. Tipografi

| Rol | Yazı tipi | Boyut / satır | Ağırlık |
|---|---|---|---|
| Ekran başlığı | **Fraunces** (serif, karakterli) | 28 / 34 | 600 |
| Bölüm başlığı | Fraunces | 20 / 26 | 600 |
| Gövde | **Inter** | 16 / 24 | 400 |
| Gövde vurgu | Inter | 16 / 24 | 600 |
| Küçük metin | Inter | 13 / 18 | 500 |
| Etiket rozeti | Inter | 11 / 14, harf aralığı +0.4 | 700, BÜYÜK HARF |
| Sayaç (hak, seri) | Inter tabular | 15 / 20 | 700 |

İkisi de ücretsiz (Google Fonts, SIL Açık Font Lisansı) ve Türkçe karakterleri (ğ, ş, ı, İ, ç, ö, ü) tam destekler.
Büyük harf dönüşümü dile duyarlı yapılır ("i" → "İ"). Sistem yazı boyutu büyütmesine (Dynamic Type) uyulur.

## 4. Boşluk, köşe, gölge

- Boşluk ölçeği (px): 4 · 8 · 12 · 16 · 24 · 32 · 48. Ekran kenar boşluğu 16.
- Köşe yarıçapı: düğme 14, kart 20, görsel 16, rozet tam yuvarlak.
- Gölge: sadece yüzen öğelerde (alt sayfa, yüzen düğme) tek yumuşak gölge. Kartlarda gölge yok, ince kenarlık var.
- Dokunma alanı en az 44×44.

## 5. Hareket

- Standart geçiş 200 ms, "yay" (spring) efekti hafif.
- Hangisi? oyu: seçilen kart %4 büyür + onay titreşimi (haptic), diğeri soluklaşır, 300 ms sonra yeni çift kayarak gelir.
- Deneme bekleme: kumaş dalgalanması animasyonu (Lottie), "hazırlanıyor" metni 3 aşamada değişir.
- "Hareketi azalt" ayarı açıksa animasyonlar sade solmaya döner.

## 6. Simgeler

Lucide simge seti (ücretsiz, açık lisans). Sabit eşleşmeler: Giyildi = `camera`, Deneme = `sparkles`,
Bende Dene = `shirt` + `sparkles`, Seri = `flame`, Şikayet = `flag`, Engelle = `ban`, Link = `shopping-bag`.

## 7. Bileşenler

| Bileşen | Açıklama |
|---|---|
| `Button` | Türler: primary / secondary / ghost / danger; boyut: L (52) / M (44); yükleniyor durumu |
| `IconButton` | Yuvarlak, 44×44 |
| `TextField` | Etiket, yardım metni, hata metni, karakter sayacı |
| `Select` / `ChipGroup` | Beden, kategori, stil tercihleri (çoklu seçim çipleri) |
| `LabelBadge` | **Giyildi** (yeşil, kamera) / **Deneme** (mor, yıldız). Görselin sol üst köşesinde, kaldırılamaz |
| `CreditBadge` | Sağ üstte "2/3" + mor yıldız; dokununca hak açıklaması ve reklam seçeneği |
| `StreakBadge` | Alev + gün sayısı |
| `OutfitCard` | Akış kartı: görsel (4:5), etiket, kullanıcı satırı, açıklama, parça çipi, Bende Dene, `···` |
| `VsPair` | Hangisi? için iki görsel + seçim animasyonu + oran çubuğu |
| `BeforeAfterSlider` | Deneme sonucu: önce/sonra sürgüsü |
| `ProductItemRow` | Parça adı, mağaza alan adı, fiyat (yerel para birimiyle), Satın al |
| `ThemeHeader` | Tema adı, geri sayım, katılım sayısı, Gönder |
| `Podium` | Dünün ilk 3'ü |
| `BottomSheet` | `(+)` menüsü, `···` menüsü, şikayet nedenleri |
| `ConsentCheckbox` | Uzun metin linkli, varsayılan boş |
| `EmptyState` | Simge + kısa metin + tek eylem |
| `Toast` | "Hakkın iade edildi" gibi kısa bildirimler |
| `ReportSheet` | Şikayet nedenleri listesi + isteğe bağlı açıklama |
| `WatermarkComposer` | Dışa aktarım için görsel + filigran birleştirme (ekranda görünmez) |

## 8. Ekran listesi

| # | Ekran | Sekme / akış |
|---|---|---|
| 1 | Karşılama (3 kart) | Kayıt |
| 2 | Giriş yöntemi | Kayıt |
| 3 | E-posta kodu | Kayıt |
| 4 | Doğum tarihi / 18+ | Kayıt |
| 5 | 18 yaş altı engel | Kayıt |
| 6 | Sözleşmeler | Kayıt |
| 7 | Profil kurulumu | Kayıt |
| 8 | Bildirim izni ön ekranı | Kayıt |
| 9 | Akış (Yeni / Bugünün teması) | Akış |
| 10 | Gönderi detayı | Akış |
| 11 | Hangisi? | Hangisi? |
| 12 | `(+)` alt menü | Ekle |
| 13 | Kombin paylaş — kaynak seç | Ekle |
| 14 | Kombin paylaş — düzenle | Ekle |
| 15 | Kombin paylaş — parçalar ve linkler | Ekle |
| 16 | Deneme hazırlık | Deneme |
| 17 | Deneme bekleme | Deneme |
| 18 | Deneme sonucu | Deneme |
| 19 | Hak bitti / reklam teklifi | Deneme |
| 20 | Dijital ikiz tanıtım | İkiz |
| 21 | Açık rıza (vücut fotoğrafı + yurt dışı aktarım) | İkiz |
| 22 | Fotoğraf rehberi | İkiz |
| 23 | Fotoğraf çek / seç / kırp | İkiz |
| 24 | Ölçüler ve tercihler | İkiz |
| 25 | Tema (bugün + dünün sonuçları) | Tema |
| 26 | Tema arşivi / geçmiş sonuç | Tema |
| 27 | Profil (kendi) | Profil |
| 28 | Profil (başkası) | Profil |
| 29 | Denemelerim (özel) | Profil |
| 30 | Ayarlar | Profil |
| 31 | Rızalarım | Ayarlar |
| 32 | Engellenenler | Ayarlar |
| 33 | Verilerimi indir | Ayarlar |
| 34 | Hesabı sil (2 adım) | Ayarlar |
| 35 | Şikayet alt sayfası | Ortak |
| 36 | Uygulama içi tarayıcı (ürün linki) | Ortak |
| 37 | Yönetici: ölçüm paneli | Yönetici |
| 38 | Yönetici: moderasyon kuyruğu | Yönetici |
| 39 | Yönetici: tema takvimi | Yönetici |
| 40 | Yönetici: sistem ayarları ve maliyet | Yönetici |

## 9. Metin tonu

- Samimi, kısa, "sen" diliyle. Örn: "Bu deneme 1 hak kullanır." / "Hakkın iade edildi, tekrar dene."
- Hata mesajı suçlamaz, çözüm söyler.
- İngilizce metinler çeviri değil, aynı tonda yeniden yazım.

## 10. Logo ve uygulama simgesi

Aşama 1'de geçici bir simge (kiremit zemin üzerinde beyaz, perdeli kabin silüeti) üreteceğim. **Bu geçicidir**;
mağaza öncesi profesyonel bir tasarımcıdan logo almanı öneririm (bkz. BENIM_ISLERIM.md).
