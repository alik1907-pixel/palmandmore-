# GATE 1 raporu: konsept seçimi

**Durum:** Yapımcı onayı bekleniyor. Seçimden sonra docs/GDD.md yazılacak ve M2 (dikey dilim) başlayacak.

## Özet
- 12 konsept üretildi ve puanlandı (docs/CONCEPTS.md).
- **Tohum fikir YANKI elendi.** Google Play'de "Echo: Time Loop Puzzles" aynı mekaniği ve aynı günlük bulmaca kancasını zaten kullanıyor.
- En yüksek puanlı 3 konsept oynanabilir greybox olarak yapıldı. Her biri 320 bot oyunuyla ölçüldü ve 10 sn'lik dikey (1080x1920) video kaydedildi.

| Sıra | Konsept | Puan /60 | Video | Bölüm 1 → 4 bot başarısı |
|---|---|---|---|---|
| 1 | **ŞİŞ**: tek tuşla şişen/sönen jöle balon | 53 | `media/m1/sis_greybox_10s.mp4` | %78 → %30 |
| 2 | **KIRILMA**: buzu çatlatıp gizli süsü ortaya çıkar | 50 | `media/m1/kirilma_greybox_10s.mp4` | %40 → %15 |
| 3 | **DALGA**: taş at, dalgalar feneri limana itsin | 47 | `media/m1/dalga_greybox_10s.mp4` | %60 → %30 |

(Videolar greybox: düz şekiller, ses yok, bot oynuyor. Sanat yönü M3'te.)

## Önerim: ŞİŞ
1. **Hibrit-gündelik kalıba en uygun olanı.** Tek girdi, 10 saniyede öğreniliyor. Bölümler kısa (~15–25 sn), bu da "bir tane daha" döngüsü ve bölüm arası reklam/ödül yerleşimi için ideal.
2. **En güçlü video kancası.** Hem başarı (dar geçitten ezilerek sıkışma) hem başarısızlık (patlama) paylaşılabilir. Araştırmaya göre viral kliplerin ortak noktası komik fizik başarısızlıkları (RESEARCH.md §3).
3. **Tek girdiden iki sonuç.** Boyut aynı anda kaldırma kuvvetini, sığmayı ve rüzgâr yelkenini belirliyor. Bu, basit kontrolle yüksek ustalaşma tavanı sağlıyor.
4. **Gelir yerleri doğal.** Patlayınca ödüllü reklamla "yama" (devam etme), balon kostümleri (kodla üretilir), sezon bileti.
5. **Asenkron sosyal kanca hazır.** Küresel patlama ısı haritası ("oyuncuların %73'ü burada patladı") hem oyun içi bilgi hem paylaşım kartı.

**Riskler:**
- Bölüm 5+ zorluk uçurumu (bot %0–2,5). Bu ayar sorunu: geçit genişliği, momentum ve rüzgâr gücü. M2'de bölümler el yapımı olacak.
- Takılma durumu (balon huniye sıkışıyor) oyuncuyu sinirlendirebilir; M2'de huni geometrisi düzeltilecek.
- Isı haritası bir backend gerektirir (Firebase/Firestore). "Sunucusuz" tercihine istisna olur; maliyeti düşük.

**İkinci tercih: KIRILMA.** En tatmin edici görsel (ASMR + ortaya çıkma anı) ve en güçlü günlük bulmaca/paylaşım kartı potansiyeli. Ama derinliği daha düşük ve zorluğu okumak zor (botlar Bölüm 1'de bile %40). Bulmaca kitlesine daha uygun.

**DALGA** en güzel ve en sakin olanı. Google Play editör seçkisi için en uygunu, ama "ben de denerim" kancası daha zayıf.

## İsteğe bağlı: pazarlanabilirlik testi (PARA HARCAR, onayın gerekir)
Seçimden önce, 3 videonun cilalı hâliyle küçük bir reklam testi yapılabilir: her video için ~50–100 $, TikTok/Meta, TR veya PH gibi düşük maliyetli bir pazar, bir "yakında" sayfasına tıklama oranı ölçülür. Hangi kancanın ilgi çektiğini gerçek insanlarla ölçmenin en ucuz yolu bu. **ONAY GEREKİYOR:** para harcama + reklam hesabı açma. Varsayılan olarak bunu yapmıyorum.

## Senden istediğim karar
1. **Konsept:** ŞİŞ (öneri) / KIRILMA / DALGA / başka bir konsept.
2. **M0 engeli:** Android SDK lisanslarını kabul etmem için onay (aşağıda).
