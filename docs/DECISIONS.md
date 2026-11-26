# DECISIONS.md — Kararlar, alternatifler, gerekçeler

## D1 — Motor: Godot 4.7.2 (GDScript) · 2026-11-26
- **Alternatifler:** Unity (reklam mediation SDK ekosistemi daha olgun; ama ikili sahne dosyaları + lisans + büyük APK), Defold (küçük, ama topluluk/eklenti daha az).
- **Gerekçe:** Metin tabanlı sahneler, headless CLI test/export, `--write-movie` ile otomatik video, lisans ücreti yok. Brief ile uyumlu.
- **Risk:** AdMob, Play Billing ve Firebase eklentilerinin 4.7 ile uyumu M5'te doğrulanacak.

## D2 — Renderer: GL Compatibility · 2026-11-26
- Düşük donanımlı Android cihazlarda en geniş uyum. Bulut makinede GPU olmadan (llvmpipe) video kaydı yapılabiliyor.

## D3 — Godot projesi `game/` alt klasöründe · 2026-11-26
- Repo kökü belgeler, medya ve scriptler için. Kökteki boş Expo dosyalarına dokunulmadı.

## D4 — Prototip mimarisi: saf simülasyon + görünüm ayrımı · 2026-11-26
- `*_sim.gd` (RefCounted, deterministik, fizik motoru kullanmaz) + `*_view.gd` (çizim/girdi) + `*_bot.gd` + `tools/*_botsim.gd`.
- Gerekçe: Headless'ta binlerce oyun hızlı simüle edilebiliyor. Replay/determinizm testleri M2'de kolaylaşacak. Godot fizik motoru deterministik değil.

## D5 — Tohum konsept YANKI elendi · 2026-11-26
- Google Play'de "Echo: Time Loop Puzzles" neredeyse aynı (RESEARCH.md §4). Brief'in "daha iyisini bulursan onu öner" maddesi uygulandı.

## D6 — FERRO ile DALGA eşitliği DALGA lehine bozuldu · 2026-11-26
- İkisi de 47 puan. Eşitlik kuralı: daha düşük teknik risk kazanır.

## D7 — Prototip ayar değişiklikleri (bot verisiyle)
- ŞİŞ: Düz tavanlı kapılar balonu sıkıştırıyordu → tam huniye çevrildi. Dikenler sadece rüzgâr bölgesi olan kapılarda (oyuncuya araç verilmeden ceza yok).
- KIRILMA: Panel üst kenardan değil, yalnızca süsün sapından asılı → oyulan bölgeler büyük parçalar hâlinde düşüyor. Çatlak süse çarpınca o yönde duruyor (en fazla bir süs parçası kırılır).
- DALGA: Taş çukur değil kabarma oluşturuyor → fener taştan uzağa itiliyor (sezgisel). Sönüm 0,99 → dalgalar ~2 sn'de yatışıyor.

## D8 — GATE 1: ŞİŞ seçildi · 2026-11-26
- Yapımcı kararı ("1.yi yap"). KIRILMA ve DALGA prototipleri `game/prototypes/` altında arşiv olarak duruyor.

## D9 — Test çerçevesi: GUT yerine GUT tarzı minimal koşucu · 2026-11-26
- GUT indirilemedi (github arşivleri ve godotengine.org proxy'de 403). `tests/test_case.gd` + `tools/run_tests.gd` aynı yapıyı (test_*.gd / test_* metotları) kullanır; ileride GUT'a geçiş kolay.

## D10 — Bölüm doğrulama botu: kural tabanlıdan planlayıcıya (MPC) · 2026-11-26
- Kural tabanlı bot her yeni engel türünde yeni kural istiyordu ve sonuçlar bot hatalarını ölçüyordu. `BalloonPlanner`, simülasyonun kopyasında 9 basma/bırakma desenini 54 kare ileri oynatıp en iyisini seçer.
- Beceri parametreleri: düşünülen desen sayısı, tepki gecikmesi (12→0 kare), hata oranı (%10→0), aşırı şişirme ve diken güvenlik payı. Uzman = çözülebilirlik kanıtı.
- Sınır: bot insan değildir. Gerçek zorluk verisi kapalı testte toplanacak.

## D11 — Fizik ayarları (bot verisiyle) · 2026-11-26
- Dikey hava direnci (son hız ~350 px/sn): eskiden 1. bölüm 2,4 sn'de bitiyordu, şimdi ~8–10 sn.
- Kaldırma kuvveti r_pop'ta doyuyor: aşırı şişirme her bölümde baskın ölüm nedeniydi (%60–90); şimdi ~%0–4.
- Aşırı şişirme patlaması 1–2. bölümlerde kapalı (her bölüm tek kavram öğretir). Uyarı süresi 0,67 → 1,2 sn.
- Rüzgâr ×0,62 ve yanal sürüklenme 1,6: balon köşeye savrulup kurtulamıyordu.
- Duvar sürtünmesi 0,9 → 0,985 (iterasyon başına) ve huni eğimi en az ~33°: balon yatık eğimlerde takılıyordu.
- Kaygan kapı ağızları (lip_slip): balon sivri köşede dengede kalıp takılıyordu.
- Dikenli boğaz: 40 px dikensiz yaka, genişlik 150 (tanıtımda 160), uzunluk ≤ 120.
- "Takıldın" gerçek oyunda başarısızlık değil; sadece doğrulayıcı 15 sn limit kullanır.
