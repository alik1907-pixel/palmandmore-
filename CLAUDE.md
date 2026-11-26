# CLAUDE.md — Proje hafızası (her oturum başında oku)

## Proje
Google Play için özgün, hibrit-gündelik (hybrid-casual) Android oyunu. Hedef: ayda 1M indirmeye ölçeklenebilir potansiyel.
Yapımcı kod yazmaz; GATE noktalarında ve riskli işlemlerde onay verir. Ayrıntılı görev tanımı: `docs/BRIEF.md`.

## Aktif milestone
**M1 → GATE 1 bekleniyor** (yapımcı 3 prototipten birini seçecek). M0 kısmen tamam: Android SDK lisans onayı bekliyor.
Durum ayrıntısı: `docs/PROGRESS.md`. Rapor: `docs/GATE1.md`.

## Teknoloji yığını
- Godot 4.7.2-stable (GDScript), renderer: GL Compatibility (düşük donanım + Xvfb/llvmpipe ile video kaydı).
- Godot projesi: `game/` (proje kökü değil!). Prototipler: `game/prototypes/<ad>/`. Araçlar: `game/tools/`.
- Android: Godot export şablonları kurulu (`~/.local/share/godot/export_templates/4.7.2.stable`). Android SDK cmdline-tools `/opt/android-sdk` (platform/build-tools kurulumu lisans onayı bekliyor).
- Hedef API: Ağustos 2026 itibarıyla yeni uygulamalar API 36 (Android 16) hedeflemeli (bkz. RESEARCH.md).

## Komutlar
- İçe aktarma (yeni `class_name` eklenince şart): `cd game && godot --headless --path . --import`
- Bot simülasyonu: `cd game && godot --headless --path . -s res://tools/<proto>_botsim.gd -- <args>`
  - DİKKAT: Script hatasında Godot debugger'da takılır. Her zaman `timeout` + `< /dev/null` kullan, çıktıyı dosyaya yaz ve `SCRIPT ERROR` ara.
- Video (dikey): `xvfb-run -a -s "-screen 0 1200x2000x24" godot --path game --rendering-driver opengl3 --resolution 360x640 --write-movie out/f.png --fixed-fps 60 --quit-after <kare> res://prototypes/<p>/<p>.tscn -- autoplay <bölüm> <beceri> <seed>` → ffmpeg ile 1080x1920 mp4.
- APK: `scripts/build_debug.sh` (SDK kurulumu tamamlanınca doğrulanacak; şu an DOĞRULANMADI).

## Kod kuralları
- Simülasyon (saf mantık, `RefCounted`, deterministik, sabit adım) ile görünüm (Node2D, girdi/çizim) ayrı dosyalarda.
- Tip çıkarımı: `max/min/abs/clamp` Variant döner → `maxf/maxi/absf` kullan veya tipi açık yaz.
- Sihirli sayı yok: denge sabitleri dosya başında `const`; M2'de tek `tuning.tres` dosyasına taşınacak.
- Her görev sonunda `docs/PROGRESS.md` güncelle + commit. Kararlar `docs/DECISIONS.md`'ye.

## Kesin yasaklar (özet)
Match-3, merge, sonsuz koşu, idle/clicker, stack, sıralama, park, ip kesme, .io klonu, bilinen oyun kopyası; yapay zeka temalı oyun;
üretken AI görseli (tüm sanat kodla); karanlık kalıplar. Onaysız: para harcama, ödeme bilgisi, hesap aç/sil, sözleşme/lisans kabulü, yayına gönderme.

## Ortam notları (bulut oturumu)
- KVM yok → Android emülatörü bu makinede ÇALIŞMAZ. Cihaz testi yapımcının telefonu/PC'si ile (adb) yapılacak.
- Xvfb + Mesa (llvmpipe) mevcut → `--write-movie` ile video üretimi çalışıyor (~%35 gerçek zaman hızı).
- Repo kökündeki boş Expo dosyaları (app.json, package.json vb.) yapımcının yüklediği dosyalar; dokunulmadı.
