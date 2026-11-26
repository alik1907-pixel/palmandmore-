# CLAUDE.md — Proje hafızası (her oturum başında oku)

## Proje
Google Play için özgün, hibrit-gündelik (hybrid-casual) Android oyunu. Hedef: ayda 1M indirmeye ölçeklenebilir potansiyel.
Yapımcı kod yazmaz; GATE noktalarında ve riskli işlemlerde onay verir. Ayrıntılı görev tanımı: `docs/BRIEF.md`.

## Aktif milestone
**M2 (dikey dilim) — kod tamam, cihaz testi bekliyor.** GATE 1: ŞİŞ seçildi (docs/GDD.md).
M0 engeli sürüyor: Android SDK lisans onayı yok → APK yok → telefon testi yok. Durum: `docs/PROGRESS.md`.

## Teknoloji yığını
- Godot 4.7.2-stable (GDScript), renderer: GL Compatibility (düşük donanım + Xvfb/llvmpipe ile video kaydı).
- Godot projesi: `game/` (proje kökü değil!). Oyun: `game/src/{sim,game,audio,core}`, bölümler `game/data/levels/NN.json`, denge `game/data/tuning.tres` (+ varsayılanlar `src/core/tuning.gd`). M1 prototipleri arşiv: `game/prototypes/`. Araçlar: `game/tools/`. Testler: `game/tests/`.
- Android: Godot export şablonları kurulu (`~/.local/share/godot/export_templates/4.7.2.stable`). Android SDK cmdline-tools `/opt/android-sdk` (platform/build-tools kurulumu lisans onayı bekliyor).
- Hedef API: Ağustos 2026 itibarıyla yeni uygulamalar API 36 (Android 16) hedeflemeli (bkz. RESEARCH.md).

## Komutlar
- İçe aktarma (yeni `class_name` eklenince şart): `cd game && godot --headless --path . --import`
- Testler: `cd game && godot --headless --path . -s res://tools/run_tests.gd` (~75 sn; çıkış kodu 0 = yeşil)
- Script derleme kontrolü: `-s res://tools/check_scripts.gd`
- Bölüm doğrulama: `-s res://tools/validate_levels.gd -- <ilk> <son> <koşu> [planner|expert|heuristic]`
- Tek tur izleme: `-s res://tools/trace.gd -- <bölüm> <beceri> <seed> <her_n_kare>`; video için tohum bulma: `-s res://tools/find_run.gd -- <bölüm> <beceri> won|popped <maks_kare>`
  - DİKKAT: Script hatasında Godot debugger'da takılır. Her zaman `timeout` + `< /dev/null` kullan, çıktıyı dosyaya yaz ve `SCRIPT ERROR` ara.
- Video (dikey): `xvfb-run -a -s "-screen 0 1200x2000x24" godot --path game --rendering-driver opengl3 --resolution 360x640 --write-movie out/f.png --fixed-fps 60 --quit-after <kare> res://src/game/game_screen.tscn -- autoplay <bölüm> <beceri> <seed> <kaç_bölüm>` → kareler + f.wav → ffmpeg ile 1080x1920 sesli mp4.
- APK: `scripts/build_debug.sh` (SDK kurulumu tamamlanınca doğrulanacak; şu an DOĞRULANMADI).

## Kod kuralları
- Simülasyon (saf mantık, `RefCounted`, deterministik, sabit adım) ile görünüm (Node2D, girdi/çizim) ayrı dosyalarda.
- Tip çıkarımı: `max/min/abs/clamp` Variant döner → `maxf/maxi/absf` kullan veya tipi açık yaz.
- Sihirli sayı yok: simülasyon dengesi yalnızca `Tuning` (data/tuning.tres) üzerinden; bölüm geometrisi sabitleri `LevelBuilder` başında. Bir tuning değeri değişince `validate_levels` + `run_tests` tekrar çalıştırılır.
- Yeni bölüm ekleyince: uzman planlayıcı çözmeli (test), karma popülasyon eğrisi kabaca azalan kalmalı.
- Her görev sonunda `docs/PROGRESS.md` güncelle + commit. Kararlar `docs/DECISIONS.md`'ye.

## Kesin yasaklar (özet)
Match-3, merge, sonsuz koşu, idle/clicker, stack, sıralama, park, ip kesme, .io klonu, bilinen oyun kopyası; yapay zeka temalı oyun;
üretken AI görseli (tüm sanat kodla); karanlık kalıplar. Onaysız: para harcama, ödeme bilgisi, hesap aç/sil, sözleşme/lisans kabulü, yayına gönderme.

## Ortam notları (bulut oturumu)
- KVM yok → Android emülatörü bu makinede ÇALIŞMAZ. Cihaz testi yapımcının telefonu/PC'si ile (adb) yapılacak.
- Xvfb + Mesa (llvmpipe) mevcut → `--write-movie` ile video üretimi çalışıyor (~%35 gerçek zaman hızı).
- Repo kökündeki boş Expo dosyaları (app.json, package.json vb.) yapımcının yüklediği dosyalar; dokunulmadı.
