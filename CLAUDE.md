# CLAUDE.md — Proje hafızası (her oturum başında oku)

## Proje
Google Play için özgün, hibrit-gündelik (hybrid-casual) Android oyunu. Hedef: ayda 1M indirmeye ölçeklenebilir potansiyel.
Yapımcı kod yazmaz; GATE noktalarında ve riskli işlemlerde onay verir. Ayrıntılı görev tanımı: `docs/BRIEF.md`.

## Aktif milestone
**M2–M8 yapılabilir kısmı tamam; yapımcı hesap işlemleri ve cihaz testi bekleniyor** (docs/LAUNCH.md).
GATE 1: ŞİŞ. GATE 2: Kâğıt Kesik (D13). Durum: `docs/PROGRESS.md`.

## Teknoloji yığını
- Godot 4.7.2-stable (GDScript), renderer: GL Compatibility (düşük donanım + Xvfb/llvmpipe ile video kaydı).
- Godot projesi: `game/` (proje kökü değil!). Oyun: `game/src/{sim,game,audio,core}`, bölümler `game/data/levels/NN.json`, denge `game/data/tuning.tres` (+ varsayılanlar `src/core/tuning.gd`). M1 prototipleri arşiv: `game/prototypes/`. Araçlar: `game/tools/`. Testler: `game/tests/`.
- Android: SDK `/opt/android-sdk` (platform 36, build-tools 36), Godot Gradle şablonu `game/android/build` (git'te yok; kurulum: `unzip ~/.local/share/godot/export_templates/4.7.2.stable/android_source.zip -d game/android/build` + `game/android/.build_version`). Editor ayarı: `~/.config/godot/editor_settings-4.7.tres` → android_sdk_path, debug_keystore.
- Yerel eklenti: `android_plugin/` (Kotlin, `./gradlew :plugin:assembleRelease`) → AAR'ı `game/addons/sis_platform/bin/SisPlatform-release.aar` üzerine kopyala.
- Autoload'lar: Profile (kayıt), Analytics, Platform (onay/reklam/ödeme/paylaşım), Music. Kök sahne `src/app/main.tscn` (ekran değiştirici + arka plan shader'ı).
- Yapılandırma: `game/data/platform.json` (AdMob/ürün kimlikleri; şu an Google TEST kimlikleri).
- Hedef API: Ağustos 2026 itibarıyla yeni uygulamalar API 36 (Android 16) hedeflemeli (bkz. RESEARCH.md).

## Komutlar
- İçe aktarma (yeni `class_name` eklenince şart): `cd game && godot --headless --path . --import`
- Testler: `cd game && godot --headless --path . -s res://tools/run_tests.gd` (~75 sn; çıkış kodu 0 = yeşil)
- Script derleme kontrolü: `-s res://tools/check_scripts.gd` (autoload kullanan dosyalar burada yanlış alarm verir; onları selftest doğrular)
- Bölüm doğrulama: `-s res://tools/validate_levels.gd -- <ilk> <son> <koşu> [planner|expert|heuristic]`
- Tek tur izleme: `-s res://tools/trace.gd -- <bölüm> <beceri> <seed> <her_n_kare>`; video için tohum bulma: `-s res://tools/find_run.gd -- <bölüm> <beceri> won|popped <maks_kare>`
  - DİKKAT: Script hatasında Godot debugger'da takılır. Her zaman `timeout` + `< /dev/null` kullan, çıktıyı dosyaya yaz ve `SCRIPT ERROR` ara.
- Video (dikey): `scripts/capture.sh` ile kareler + f.wav → ffmpeg ile 1080x1920 sesli mp4 (örnek: docs/PROGRESS.md M7).
- APK hızlı (eklentisiz): `godot --headless --path game --export-debug "Android" ../build/android/sis-debug.apk`
- APK telefon testi (eklentili, Gradle): `--export-debug "Android Gradle APK" ../build/android/sis-gradle-debug.apk`
- Yayın AAB (imzalı): `scripts/build_release.sh` (anahtar `secrets/`, git'te yok)
- Uçtan uca arayüz testi: `cd game && godot --headless --path . -- selftest` → `SELFTEST_DONE`, hata yok
- Mağaza görüntüsü/video kaydı: `scripts/capture.sh <dizin> <kare> <fps> [demo] [lang xx] [style s] (shot home|skins|themes|settings | autoplay ...)`
- Kısa video klipleri: `scripts/director.py [tarif...]` → `media/clips/` + `clips.csv`
- Günlük havuz: `-s res://tools/gen_daily.gd -- <adet> <tohum> <çıktı>`; par süreleri: `-s res://tools/compute_par.gd`; ikon: `xvfb-run ... -s res://tools/make_icon.gd`
- Not: `-s` ile çalışan araçlarda autoload yok; autoload kullanan kodu oyunu çalıştırarak doğrula.

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
