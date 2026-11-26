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
