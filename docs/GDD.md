# GDD.md: ŞİŞ (çalışma adı)

_GATE 1: yapımcı onayı 2026-11-26. Bu belge tek doğruluk kaynağıdır; değişiklikler DECISIONS.md'ye işlenir._

## 1. Bir cümlede
Tek tuşla şişip sönen jöle bir balonu dikenli, rüzgârlı, daracık bir kuyu boyunca yukarı çıkar: şişmek yükseltir ama seni büyütür; dar geçitlerden ancak tam zamanında sönerek, momentumla kayıp geçersin.

## 2. Hedef kitle ve platform
- Android (min API 24, hedef API 36), dikey, tek elle oynanır. Yaş 13+ (Aileler programına girmez).
- Oturum 3–8 dk, bölüm 15–40 sn. Hibrit-gündelik: hiper-gündelik kadar kolay giriş, gündelik kadar meta.

## 3. Çekirdek mekanik
| Girdi | Sonuç |
|---|---|
| Basılı tut | Yarıçap büyür (70 px/sn) → kaldırma kuvveti artar → yükselir; rüzgârda daha çok sürüklenir (yelken ∝ r²) |
| Bırak | Yarıçap küçülür (85 px/sn) → batar; dar yerlere sığar; rüzgâra direnir |

- **Nötr boyut** (r=42): süzülür. Büyük → yükselir, küçük → batar. Hassas bas-bırak ile havada durulabilir (ustalık).
- **Fazla şişme (Bölüm 3'ten itibaren):** r > 64 iken 1,2 sn'den uzun basılı tutulursa balon patlar (kırmızılaşır, titrer, tik sesi hızlanır = uyarı). Kaldırma kuvveti r=64'te doyar: kırmızı bölge daha hızlı tırmandırmaz, sadece rüzgârda daha büyük yelken verir (riskli taktik).
- **Hava direnci:** dikey ve yatay sürüklenme; tam şişkin balonun son hızı ~350 px/sn → süzülme hissi.
- **Takılma başarısızlık değildir:** oyuncu her zaman söndürüp tekrar deneyebilir. Kapı ağızları "kaygan": köşede dengede kalınmaz.
- **Dikenler:** temas = patlama.
- **Yumuşak gövde:** 18 düğümlü halka (Verlet + yay + basınç). Balon ezilir, sıkışır, sekip yuvarlanır. Bu his oyunun kimliği.

## 4. Engel sözlüğü (öğretim sırası)
| Engel | İlk bölüm | Ne öğretir |
|---|---|---|
| Geniş huni kapı | 1 | Bas = yüksel |
| Dar kapı (balon > boşluk) | 2 | Doğru anda bırak, momentumla kay |
| Kapı ritmi | 3 | Bas-bırak döngüsü |
| Rüzgâr bölgesi | 4 | Boyut = yelken: büyük sürüklenir |
| Dikenli huni kenarı | 5 | Yanlış hizada yükselme = ölüm |
| Fazla şişme patlaması | 3 | Kırmızıya dönünce bırak |
| Boğaz (dar baca) | 6 | Küçükken momentumu korumak |
| Diken tavanı (bar) | 9 | Süzülme: havada durup rüzgârla kenara kaymak |
| Dikenli boğaz (40 px güvenli yaka + diken) | 10 | Ortalanmış ve ölçülü boyutla tırmanmak |
| Kombinasyonlar | 11–15 | Ustalık |

## 5. Döngüler
- **Çekirdek (30 sn):** bölüm → başarı/patlama → anında yeniden (≤ 0,5 sn) veya sonraki bölüm.
- **Oturum (5 dk):** 6–10 bölüm, her 5 bölümde bir yeni engel.
- **Meta (M4):** bölge haritası, günlük kuyu (herkese aynı tohum), seri, kostümler, haftalık "en az patlama" ligi, küresel patlama ısı haritası.

## 6. Hissiyat (juice) listesi
- Patlama: 6 karelik hit-stop, ekran sarsıntısı, lastik parçacıkları, beyaz flaş, haptik (60 ms), patlama sesi.
- Duvar teması: darbe şiddetine bağlı gıcırtı (perde ∝ hız), toz parçacığı, hafif haptik.
- Sıkışma: zıt duvarlara aynı anda temas = "sıkışma" anı → lastik gerilme sesi, ilk sıkışmada konfeti kıvılcım.
- Kıl payı: dikene < 12 px yaklaşıp kurtulma → 0,4 sn yavaş çekim (sim adımları atlanarak; determinizm bozulmaz).
- Şişirme/söndürme: boyuta bağlı perdeli tıslama döngüleri. Fazla şişme: kırmızılaşma + titreme + hızlanan tik.
- Yüz: gözler hız yönüne bakar, göz kırpar, büyükken zorlanır, dikene yakınken korkar, kazanınca mutlu.
- Kazanma: konfeti, arpej, mutlu yüz.

## 7. Yazısız öğretici
- Bölüm 1: ekranda nabız gibi atan "parmak bas" ikonu; oyuncu 0,5 sn basılı tutunca kaybolur.
- Bölüm 2: ilk dar kapıya yaklaşırken balon hâlâ büyükse "parmağı kaldır" ikonu belirir.
- Bölüm 3: balon kırmızıya dönünce "titreyen kırmızı balon + kalkan parmak" ikonu.
- Bölüm 4: rüzgârda "büyü = sürüklen" ikonu (balon + ok).
- Metin yok; tüm ipuçları ikon ve animasyon.

## 8. Determinizm
- Sim sabit 60 Hz adım, rastgelelik yok (görsel efektler hariç; onlar simülasyonu etkilemez).
- Replay = kare başına 1 bitlik girdi dizisi. Aynı girdi → aynı sonuç (otomatik test). Günlük kuyu çözümleri ve hayalet replay'ler bu sayede mümkün.

## 9. Gelir yerleri (M5'te ayrıntı)
- Patlayınca: "Yama" (kaldığın yerden devam) → ödüllü reklam, bölüm başına 1 kez.
- Kostümler (kodla üretilen desen/yüz/iz), sezon bileti, reklamsız paket.
- Geçiş reklamı: ilk 10 bölümde yok.

## 10. Teknik
- Godot 4.7.2, GL Compatibility. Sim: `game/src/sim/`, görünüm: `game/src/game/`, ses sentezi: `game/src/audio/`.
- Denge değerleri: `game/data/tuning.tres` (tek dosya). Bölümler: `game/data/levels/*.json`.
- Bölüm doğrulama: `BalloonPlanner` (simülasyon kopyasında 54 kare ileri bakan MPC bot). Uzman (beceri 1,0) her bölümü kazanmalı (otomatik test). Karma beceri popülasyonunun başarı eğrisi kabaca azalan olmalı.

## 12. Bölüm listesi (M2)
1 İlk Nefes · 2 Dar Kapı · 3 Ritim · 4 Esinti · 5 Dikenli Huni · 6 Boğaz · 7 Fırtına · 8 Uzun Yol · 9 Tavan · 10 Dikenli Boğaz · 11 Zikzak Tavan · 12 Ters Rüzgâr · 13 Zirve · 14 Eldiven · 15 İğne Deliği

## 13. Meta ve uygulama akışı (M4, uygulandı)
- **Ana menü:** canlı maskot (gerçek BalloonSim; basılı tutunca şişer), yıldız sayacı, günlük kuyu kartı (#numara + 🔥 seri), 15 bölüm ızgarası (★ 0–3, kilit), OYNA (sıradaki bölüm), Balonlar / Temalar / Reklamsız düğmeleri, Ayarlar.
- **Yıldızlar:** ★ bitir · ★★ par×2,0 altında · ★★★ par×1,35 altında. Par = uzman planlayıcı süresi (`tools/compute_par.gd`). Yama kullanılırsa en fazla ★.
- **Günlük kuyu:** herkese aynı (yerel tarih), 60 doğrulanmış bölümlük havuz; seri dün/bugün oynandıysa sürer; aynı gün tekrar oynamak seriyi şişirmez; günlük en iyi süre saklanır.
- **Kozmetik:** 10 balon (yıldız ve seri eşikleri, 1 ödüllü reklam, 1 IAP), 3 tema (varsayılan Kâğıt Kesik; Neon Gece 25★; Pastel Gün 40★; "Tüm temalar" IAP).
- **Paylaşım:** sonuç ekranında sistem paylaşım menüsü; metin: "ŞİŞ Günlük #N 🎈 14.2 sn ⭐⭐⭐ 🔥5 + mağaza linki" (15 dilde).
- **Değerlendirme isteği:** 6. bölüm ilk kez ★★★ ile bitince, bir kez (Play In-App Review).
- **Ayarlar:** ses, müzik, titreşim, dil (15 dil: TR, EN, ES, PT, ID, HI, DE, JA, FR, IT, RU, KO, ZH, VI, TH; varsayılan sistem dili, desteklenmiyorsa İngilizce), reklamsız, satın alımları geri yükle, gizlilik seçenekleri (UMP gerekiyorsa), gizlilik politikası.
- **Android:** geri tuşu (panel kapat → menü → çıkış), arka plana atılınca basılı tutma bırakılır, çoklu parmak desteği.

## 14. Ses ve müzik (M3, uygulandı)
- SFX: sentez (patlama, gıcırtı, sıkışma, tıslama/söndürme döngüleri, rüzgâr, tik, vınlama, arpej).
- Müzik: 4 katmanlı uyarlanabilir döngü (pad, bas, arpej, perküsyon; Am–F–C–G, 120 BPM), işçi iş parçacığında açılışta sentezlenir. Menüde sadece pad; oyunda bas; büyüklükle arpej; rüzgâr/yüksek ilerlemede perküsyon.

## 11. Açık sorular
- Isı haritası ve uzak analitik backend'i (Firebase): yapımcı kararı bekliyor (D17). Olaylar zaten konumla kaydediliyor (level_fail x/y).
- Oyunun son adı ve mağaza dili, M7'de ASO araştırmasıyla.
