# PROGRESS.md — Milestone durumu

_Son güncelleme: 2026-11-26_

## M0 — Ortam: KISMEN TAMAM (engelli)
- [x] Godot 4.7.2 + Android export şablonları, Xvfb video kaydı, headless test/sim.
- [ ] **ENGEL (yapımcı onayı):** Android SDK lisans kabulü → platform-tools, build-tools 36, platform 36 → APK.
- [ ] **ENGEL:** Bu makinede emülatör yok (KVM yok). Cihaz testi yapımcının telefonu/PC'si ile.

## M1 — Fikir: TAMAM
- GATE 1 → **ŞİŞ** seçildi (2026-11-26). Rapor: docs/GATE1.md.

## M2 — Dikey dilim: KOD TAMAM, CİHAZ TESTİ BEKLİYOR
- [x] GDD yazıldı (docs/GDD.md).
- [x] Deterministik yumuşak gövde simülasyonu `BalloonSim` (tüm denge `Tuning` kaynağında), olay yayını (pop/hit/squeeze/near_miss/won).
- [x] Bölüm formatı (JSON) + `LevelBuilder`: kapı, huni, dikenli huni, rüzgâr, boğaz, dikenli boğaz (güvenli yaka), diken tavanı, duvar dikeni.
- [x] 15 el yapımı bölüm (her biri bir engel öğretir, sonra kombinasyon).
- [x] Oyun ekranı: kamera, Catmull-Rom yumuşak balon çizimi, yüz ifadeleri (bakış, göz kırpma, zorlanma, korku, mutluluk), iz, rüzgâr çizgileri, ilerleme çubuğu, ikonla tekrar/sonraki.
- [x] Juice: hit-stop (6 kare), sarsıntı, flaş, parçacıklar, konfeti, kıl payı yavaş çekim, haptik (mobilde).
- [x] Sentez sesler (dosya yok): patlama, gıcırtı, sıkışma, tıslama/söndürme döngüleri (perde boyuta bağlı), rüzgâr, tik, vınlama, kazanma arpeji.
- [x] Yazısız öğretici: bas (B1), bırak (B2), aşırı şişme (B3), rüzgâr (B4) ikonları.
- [x] İlerleme kaydı (`user://save.cfg`).
- [x] Testler 10/10 yeşil: replay birebir aynı sonuç, aynı girdi = aynı hash, klon bağımsızlığı, kurallar, uzman 15/15 bölümü çözüyor, sim adımı ~88 µs.
- [x] Bölüm doğrulama (karma beceri, 40 koşu): `media/m2/levels_validation_40runs.jsonl`
  - Kazanma: B1–9 %92–100 · B10 %62,5 · B11 %47,5 · B12 %42,5 · B13 %25 · B14 %22,5 · B15 %22,5. Ölümlerin neredeyse tamamı dikenlerden; aşırı şişirme ≤ %5.
- [x] Video: `media/m2/sis_vertical_slice.mp4` (42 sn, sesli, 1080x1920).
- [ ] Girdi gecikmesi ≤ 1 kare: kodda girdi sonraki fizik adımında okunuyor (≤16,7 ms). Cihazda ölçülmedi: DOĞRULANMADI.
- [ ] Düşük donanımda 60 FPS: DOĞRULANMADI (APK yok).
- [ ] "Talimatsız oyuncu 60 sn'de B1'i bitirir": bot B1'i ~10 sn'de %100 bitiriyor; **insan testi bekliyor**.

## Açık sorunlar / sonraki adımlar
- APK + telefon testi (M0 engeli).
- Bot ≠ insan: 1–9. bölümler botlar için çok kolay (%90+). İnsan verisiyle yeniden ayarlanacak.
- Aşırı şişirme kırmızı bölgesinin "rüzgârda yelken" taktiği, bölüm tasarımında henüz bilinçli kullanılmıyor.
- Sanat yönü (M3, GATE 2), müzik yok (M3).
- Repo kökündeki boş Expo dosyaları duruyor (yapımcı karar vermedi).
