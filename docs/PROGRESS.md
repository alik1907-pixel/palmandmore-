# PROGRESS.md — Milestone durumu

_Son güncelleme: 2026-11-26_

## M0 — Ortam: KISMEN TAMAM (engelli)
- [x] OS tespiti: Linux x86_64 bulut konteyneri, 4 çekirdek, 15 GB RAM. **KVM yok.**
- [x] Godot 4.7.2-stable (son kararlı sürüm) kuruldu: `/opt/godot`, `godot` komutu.
- [x] Godot Android export şablonları kuruldu.
- [x] Godot projesi (`game/`) oluşturuldu; headless çalıştırma ve Xvfb ile `--write-movie` video kaydı doğrulandı.
- [x] JDK: sistemde OpenJDK 21 var (brief JDK 17 diyor). Godot 4.7 ile uyum APK aşamasında doğrulanacak: DOĞRULANMADI.
- [x] Android SDK cmdline-tools indirildi (`/opt/android-sdk`).
- [ ] **ENGEL:** `platform-tools`, `build-tools;36.0.0`, `platforms;android-36` kurulumu için Android SDK lisans sözleşmelerini kabul etmek gerekiyor. Kurallar gereği yapımcı onayı bekleniyor.
- [ ] `scripts/build_debug.sh`: yazıldı, SDK kurulana kadar test edilemiyor.
- [ ] **ENGEL:** Emülatör bu makinede çalışmaz (KVM yok). Alternatif: yapımcının telefonu (USB hata ayıklama + adb) veya yapımcının PC'si (Remote Control ile bağlanırsa).

## M1 — Fikir üretimi ve eleme: GATE 1 BEKLİYOR
- [x] Pazar/politika araştırması: docs/RESEARCH.md
- [x] 12 konsept + ağırlıklı puanlama: docs/CONCEPTS.md
- [x] 3 greybox prototip (ŞİŞ, KIRILMA, DALGA): `game/prototypes/`
- [x] Her biri 8 bölüm × 40 bot = 320 oyun; sonuçlar `media/m1/*_botsim.jsonl`
- [x] 10 sn dikey videolar: `media/m1/*_greybox_10s.mp4`
- [x] GATE 1 raporu: docs/GATE1.md
- [ ] Yapımcı seçimi → docs/GDD.md

## Açık sorunlar
- ŞİŞ: Bölüm 5+ zorluk uçurumu; huniye takılma.
- KIRILMA: bot başarısı düşük (bot zayıflığı mı, tasarım mı? İnsan testi gerekli).
- DALGA: Bölüm 7 %0.
- Repo kökünde boş Expo/React Native dosyaları var (app.json, package.json, eas.json vb.); yapımcıya soruldu, dokunulmadı.
