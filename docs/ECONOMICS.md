# ECONOMICS.md: Gelir modeli ve birim ekonomisi

_2026-11-26. Kaynaklar RESEARCH.md §1, §2 ve §6'da. Rakamlar aralık olarak verildi, çünkü kaynaklar birbiriyle çelişiyor. Gerçek değerler yumuşak lansmanda ölçülecek._

## 1. Gelir modeli (oyunda uygulanmış hâli)
| Kaynak | Yer | Kural |
|---|---|---|
| Ödüllü reklam: **Yama ile devam** | Patlama ekranı | Deneme başına 1 kez; kaldığın yerin ~1,5 sn öncesinden devam. Yama kullanılan tur en fazla 1★ alır ve rekor kaydetmez (reklamla kazanma avantajı yok). |
| Ödüllü reklam: **Hayalet balon** | Balonlar paneli | 1 reklam = kalıcı kostüm. |
| Geçiş reklamı | Sadece bölüm sonu → "sonraki" geçişi | 10. bölümden önce asla; en az 180 sn ve 2 bölüm arayla; bölüm ortasında asla; reklamsız pakette hiç. |
| IAP `remove_ads` | Ayarlar + ana menü | Geçiş reklamlarını kaldırır; ödüllü reklamlar isteğe bağlı kalır. Önerilen fiyat: 2,99 $. |
| IAP `theme_pack` | Temalar paneli | Neon Gece + Pastel Gün temaları. Önerilen: 1,99 $. |
| IAP `cosmetic_pack` | Balonlar paneli | Gökkuşağı balon. Önerilen: 0,99 $. |
| Ücretsiz kilit açma | Yıldızlar / günlük seri | 8 kostüm ve 2 tema oynayarak açılır (kazan-için-öde yok). |

Mediation: AdMob (bidding). Ek ağlar (AppLovin, Unity, Liftoff) AdMob mediation adaptörleriyle sonradan eklenebilir; kod tarafında değişiklik gerekmez, adaptör bağımlılığı `sis_platform_editor.gd` DEPS listesine eklenir. DOĞRULANMADI: adaptör sürüm uyumu.

## 1b. Jeton ekonomisi (oyun içi, D25)
| Kaynak | Miktar |
|---|---|
| Bölüm bitirme | 5 + 5×★ (5–20) |
| Günlük kuyu (günün ilki) | +50 |
| Günlük görevler | 3 × 40–120, hepsi +100 |
| Ödüllü "2× jeton" | bölüm ödülü kadar |
| **Harcama** | 12 balon 150–1200 · Neon Gece 1500 · Pastel Gün 2500 |
"2× jeton" yeni bir ödüllü reklam yeri: bölüm sonunda, isteğe bağlı. Oturum başına izleme oranı yumuşak lansmanda ölçülecek (ARPDAU'nun ana kaldıracı).

## 2. 12 aylık LTV senaryoları (yükleme başına)
Yöntem: D1, D7 ve D30'dan parçalı güç yasası tutma eğrisi uydurulur, 365 gün toplanır, ARPDAU aralığıyla çarpılır.
ARPDAU varsayımları: Tier-1 için 0,08–0,20 $, gelişen pazarlar için 0,015–0,04 $. Kaynak: hibrit-gündelik için 0,15–0,50 $ bildiriliyor, sadece reklamla ~0,03 $. Yeni bir oyun için temkinli alındı.

| Senaryo | D1/D7/D30 | 365 günde oyuncu başına aktif gün | LTV Tier-1 | LTV gelişen pazar |
|---|---|---|---|---|
| Kötü | %30 / %8 / %2,5 | 5,4 | 0,43–1,07 $ | 0,08–0,21 $ |
| Orta | %38 / %13 / %4,5 | 8,8 | 0,71–1,77 $ | 0,13–0,35 $ |
| İyi (hedef) | %45 / %18 / %7 | 13,6 | 1,09–2,71 $ | 0,20–0,54 $ |

## 3. Kararlar
- **Ücretli kullanıcı edinimi (UA) ancak LTV > CPI ise.** Tier-1 hibrit-gündelik CPI kaynaklarda 1–6 $. "İyi" senaryoda bile Tier-1 UA marjinal. Bu yüzden büyüme planı organik kısa video + ASO + yayıncı (bkz. docs/LAUNCH.md, docs/PUBLISHER_PITCH.md).
- Gelişen pazarlarda CPI ~0,1–0,4 $ olabilir. "Orta" senaryoda LTV 0,13–0,35 $, yani başa baş sınırında. Yumuşak lansman bu pazarlarda KPI ölçmek içindir, kâr için değil.
- **1M indirme/ay için hesap:** organik + öne çıkarılma olmadan, 1M yükleme × 0,5 $ CPI = 500 bin $/ay UA bütçesi gerekir. Bu, yayıncı ortaklığı veya viral büyüme olmadan gerçekçi değil.

## 4. Doğrulanacaklar (yumuşak lansmanda)
ARPDAU (reklam + IAP ayrı), ödüllü reklam izleme oranı (DAU başına), reklamsız paket dönüşümü, eCPM (ülke bazında), Yama kabul oranı.
