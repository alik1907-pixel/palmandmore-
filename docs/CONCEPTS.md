# CONCEPTS.md — M1: 12 konsept, ağırlıklı puanlama, prototip sonuçları

## Puanlama yöntemi
1–5 puan, ağırlıklar: Video kancası ×3 · Tek parmak/10 sn'de öğrenme ×2 · Derinlik ×2 · Özgünlük ×2 · Kodla şık görsel ×1 · Gelir uyumu ×1 · Teknik risk ×1 (5 = düşük risk). Maksimum 60.
Özgünlük puanları RESEARCH.md §4'teki taramaya dayanır. Diğer puanlar tasarım yargısıdır (ölçüm değil).

## Puan tablosu

| # | Konsept | Kanca ×3 | Tek parmak ×2 | Derinlik ×2 | Özgünlük ×2 | Görsel ×1 | Gelir ×1 | Tek. risk ×1 | **Toplam** |
|---|---|---|---|---|---|---|---|---|---|
| 2 | **ŞİŞ** | 5 | 5 | 4 | 4 | 4 | 4 | 4 | **53** |
| 4 | **KIRILMA** | 5 | 5 | 3 | 4 | 5 | 3 | 3 | **50** |
| 3 | **DALGA** | 4 | 5 | 4 | 3 | 5 | 3 | 3 | **47** |
| 6 | FERRO | 5 | 4 | 3 | 5 | 4 | 3 | 1 | 47 |
| 9 | REZONANS | 4 | 5 | 2 | 4 | 4 | 3 | 5 | 46 |
| 8 | YANGIN HATTI | 4 | 4 | 4 | 3 | 4 | 3 | 4 | 45 |
| 5 | SÜRÜ | 4 | 5 | 3 | 2 | 5 | 3 | 3 | 43 |
| 12 | GÖLGE GÜNEŞİ | 3 | 5 | 4 | 3 | 4 | 3 | 3 | 43 |
| 11 | YÖRÜNGE | 3 | 4 | 4 | 2 | 5 | 3 | 4 | 41 |
| 1 | YANKI (tohum) | 4 | 3 | 4 | 1 | 4 | 4 | 3 | 39 |
| 10 | KUM SAATİ | 4 | 4 | 3 | 1 | 4 | 3 | 3 | 38 |
| 7 | SONAR | 3 | 4 | 3 | 1 | 5 | 3 | 4 | 37 |

Eşitlik kuralı: DALGA ile FERRO 47'de eşit. Daha düşük teknik risk kazanır (1 günlük prototip sınırı), bu yüzden DALGA seçildi. FERRO'nun asıl riski, düşük donanımlı telefonda 60 FPS'te ferroakışkan (SPH + metaball) çalıştırmak.

**Tohum fikir YANKI elendi:** Google Play'de "Echo: Time Loop Puzzles" aynı mekaniği ve aynı günlük bulmaca kancasını zaten kullanıyor.

---

## Konseptler

### 1. YANKI (tohum fikir)
- **Pitch:** Her denemen bir "yankı" olur ve sonraki denemende seninle birlikte oynar.
- **3 sn kanca:** 6 renkli yankının senkron koreografisi.
- **Çekirdek (30 sn):** Hareket et, düğmeye bas, başarısız ol, yankınla tekrar dene. **Oturum (5 dk):** 4–6 bölüm. **Meta:** Günlük bulmaca, yankı sayısına göre lig.
- **Asenkron sosyal:** Başkalarının çözümlerini hayalet olarak izlemek. **Sanat:** Neon izler. **Gelir:** Ekstra yankı için ödüllü reklam.
- **Sorun:** Özgünlük 1. Ayrıca serbest hareket gerektiriyor; tek parmak için zayıf.

### 2. ŞİŞ ⭐
- **Pitch:** Tek tuş: basılı tut, balon şişip yükselir; bırak, söner ve batar. Dar geçitten geçmek için tam doğru anda sönmen, dikenlere değmeden tekrar şişmen gerekir.
- **3 sn kanca:** Balonun jöle gibi ezilerek dar bir boşluktan sıkışması, ya da patlama anı (komik başarısızlık klibi).
- **Çekirdek (30 sn):** Momentum biriktir (şiş) → geçide yaklaşırken sön → içinden kay → yeniden şiş. Boyut iki şeyi birden belirler: kaldırma kuvveti ve rüzgârdaki yelken etkisi. Büyük balon rüzgârla daha çok sürüklenir; yatay kontrol de buradan gelir.
- **Oturum (5 dk):** 6–10 kısa bölüm (her biri ~15–25 sn). **Meta:** Balon kostümleri (kodla: desen, yüz, iz), bölge haritası, haftalık "en az şişirme" ligi.
- **Asenkron sosyal:** Her bölümde, oyuncuların balonu en çok nerede patlattığını gösteren küresel ısı haritası ("oyuncuların %73'ü burada patladı"). Bu aynı zamanda paylaşım kartı.
- **Sanat:** Yumuşak gövde deformasyonu + shader (gloss, gerilme rengi). **Gelir:** Patladıktan sonra ödüllü reklamla "yama" (devam), kostümler, reklamsız paket.
- **Risk-ödül:** Fazla şişirmek hız kazandırır ama patlatır. Geç sönmek geçide çarptırır, erken sönmek düşürür.

### 3. DALGA ⭐
- **Pitch:** Gölete taş at. Dalgalar yayılır, kayalardan yansır, birbirine karışır ve yüzen feneri limana iter.
- **3 sn kanca:** Girişim desenleri (görsel olarak çok güçlü), fenerin dalga sırtında süzülüp limana girmesi.
- **Çekirdek:** Taşı nereye attığın önemli. Yakın atılan taş güçlü iter ama dik dalga feneri devirir (risk-ödül). **Oturum:** 5–8 bulmaca. **Meta:** Günlük gölet ("3 taşta çözdüm"), fener koleksiyonu.
- **Sanat:** Dalga denklemi ızgarası + su shader'ı. Sakin/ASMR tonu, Google Play editör seçkisine uygun.
- **Gelir:** Ekstra taş, ipucu (ideal atış noktasını 3 sn göster).

### 4. KIRILMA ⭐
- **Pitch:** Kancaya asılı bir buz panelinin içinde bir süs gizli. Buza dokununca, damarının yönünde çatlıyor. Bağlantısı kopan her parça düşüyor. Az vuruşla, süse zarar vermeden süsü ortaya çıkar.
- **3 sn kanca:** Büyük buz bloklarının kopup düşmesi ve altından altın şeklin çıkması (ASMR + "reveal").
- **Çekirdek:** Her parçanın damar çizgisini okuyup çatlağın gideceği yönü tahmin et. Çatlak süse değerse süs hasar alır. **Oturum:** 6–10 heykel. **Meta:** Günlük heykel (herkese aynı panel), koleksiyon vitrini.
- **Sanat:** Voronoi mozaiği, kırılma shader'ı, kırılma sesleri sentezle üretilir. **Gelir:** Ekstra vuruş, "röntgen" ipucu.

### 5. SÜRÜ
Parmakla yüzlerce kuştan oluşan bir sürüyü engellerin arasından geçir, sürünün yüzde kaçını kurtardığın puanlanır. Görsel olarak güçlü, ama Flocc ve Murmuration bu alanı zaten kullanıyor.

### 6. FERRO
Mıknatısı sürükleyerek ferroakışkan bir damlayı labirentten geçir. Damlanın dikenleşmesi TikTok'ta zaten viral bir görüntü. Teknik riski çok yüksek.

### 7. SONAR
Karanlık labirentte "ping" gönder, duvarlar bir an için görünsün. Bu mekaniği kullanan çok oyun var (Echo, Dark Echo).

### 8. YANGIN HATTI
Tek kıvılcım bırak; rüzgâra bağlı yangın yayılımı (hücresel otomat) hedefleri yakar, evleri korur. Gerçek orman yangınlarıyla tema hassasiyeti var.

### 9. REZONANS
Basılı tutunca ses frekansı yükselir, bırakınca kilitlenir. Doğru frekansta sadece hedef bardaklar kırılır. Kanca iyi, derinlik sınırlı.

### 10. KUM SAATİ
Telefonu eğerek kumu kalıba dök. Kum/blok bulmacaları 2026'da zaten doyuyor.

### 11. YÖRÜNGE
Çekim kuyuları yerleştir, kuyruklu yıldız sapan etkisiyle hedefe gitsin. Benzer oyunlar var.

### 12. GÖLGE GÜNEŞİ
Güneşi sürükle; nesnelerin gölgesi otomatik yürüyen karakter için platform olur. Orta özgünlük.

---

## Prototip sonuçları (greybox, her biri 8 bölüm × 40 bot = 320 oyun)

Botların becerisi 0'dan 1'e eşit dağıtıldı (tepki gecikmesi, hata oranı, atış hassasiyeti), böylece bir oyuncu kitlesini kaba şekilde temsil ediyor. **Bot, insan değildir:** bu sayılar zorluk eğrisinin şeklini gösterir, gerçek tutma oranını değil.

| Bölüm | ŞİŞ kazanma | ŞİŞ patlama | KIRILMA kazanma | KIRILMA süs hasarı | DALGA kazanma | DALGA devrilme |
|---|---|---|---|---|---|---|
| 1 | %77,5 | %0 | %40 | %19 | %60 | %5 |
| 2 | %75 | %0 | %22,5 | %14 | %32,5 | %5 |
| 3 | %42,5 | %38 | %20 | %28 | %20 | %7,5 |
| 4 | %30 | %33 | %15 | %18 | %30 | %7,5 |
| 5 | %0 | %53 | %2,5 | %18 | %25 | %2,5 |
| 6 | %2,5 | %10 | %7,5 | %22 | %12,5 | %5 |
| 7 | %0 (takılma) | %0 | %17,5 | %14 | %0 | %10 |
| 8 | %0 (takılma) | %0 | %2,5 | %19 | %17,5 | %12,5 |

**Yorum:**
- **ŞİŞ:** İlk 4 bölümün eğrisi sağlıklı. 5. bölümden sonra uçurum var. 7–8'de geçit, balonun sönmüş çapına yakın ve botlar takılıyor. Bu ayarlanabilir bir sorun (geçit genişliği/momentum), tasarım hatası değil.
- **KIRILMA:** Bölüm 1 bile zor (%40). Tek adım ileriye bakan bot, ancak 2–3 vuruşta sonuç veren "kontur kesme" hamlelerini göremiyor; insan muhtemelen daha başarılı olur. Şekle bağlı oynaklık var (anahtar şekli 7. sırada, beklenenden kolay).
- **DALGA:** En düzgün eğri. Bölüm 7 (zikzak kanal) yeniden tasarlanmalı.

Videolar `media/m1/*_greybox_10s.mp4`, kare özetleri `media/m1/*_sheet.png`, ham sonuçlar `media/m1/*_botsim.jsonl`.
