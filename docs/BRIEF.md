# BRIEF.md: Yapımcının görev tanımı (özet; tam metin yapımcının ilk mesajında)

**Görev:** Google Play için özgün, ayda 1M indirmeye ölçeklenebilir hibrit-gündelik Android oyununu fikirden mağazaya kadar uçtan uca üretmek. Yapımcı kod yazmaz.

**Gerçeklik:** Her aşama ölçülebilir kapılarla ilerler. Varsayılmaz, ölçülür. Politikalar resmi kaynaktan doğrulanır, doğrulanamayan "DOĞRULANMADI" diye işaretlenir.

**Yasaklar:** Match-3, merge, sonsuz koşu, idle/clicker, stack, sıralama, park, ip kesme, .io, kopya; yapay zeka teması; üretken AI görseli (tüm görsel ve ses kodla üretilir); karanlık kalıplar.

**Onaysız asla:** para harcama, ödeme bilgisi, hesap aç/sil, sözleşme/politika kabulü, yayına gönderme, proje dışı dosya silme → "ONAY GEREKİYOR: <ne, neden, risk>".

**Bilgisayar kontrolü:** Önce CLI. Aynı GUI işlemi en fazla 3 deneme. Uzun komutlarda zaman aşımı. Şifreler dosyaya düz metin yazılmaz.

**Milestone'lar:**
- M0 Ortam (Godot, JDK 17, SDK, emülatör, tek komutla APK).
- M1 Fikir: araştırma → 12 konsept → ağırlıklı puan → 3 greybox + 200+ bot oyunu + 10 sn dikey video → **GATE 1**.
- M2 Dikey dilim: kusursuz his, 60 FPS, juice, yazısız öğretici + 15 bölüm, determinizm testi.
- M3 Sanat/ses: 3 stil → **GATE 2**; kodla görsel, sentez ses, dinamik müzik, erişilebilirlik.
- M4 Tutma/meta: günlük bulmaca, seri, 100+ bölüm (çözülebilirlik botu), lig, kozmetik, sezon, paylaşım kartı, analitik şeması.
- M5 Gelir: ödüllü reklam (isteğe bağlı), sınırlı geçiş reklamı (ilk 10 bölüm yok), IAP (reklam kaldır, kozmetik, sezon bileti), mediation + UMP, ECONOMICS.md LTV senaryoları.
- M6 Kalite: GUT, replay testleri, stres, adb ölçümleri, Vitals hedefleri, AAB < 60 MB.
- M7 Mağaza/politika: güncel kurallar, ASO, 8+ dil, scriptle mağaza görselleri, A/B setleri, öne çıkarma başvurusu → **GATE 3**.
- M8 Kapalı test (12 kişi/14 gün), yumuşak lansman + KPI kapıları (en fazla 3 iterasyon), yönetmen modu video motoru (haftada 20+ klip), yayıncı sunumu.

**Çalışma düzeni:** plan → uygula → test → PROGRESS.md → commit. Her milestone sonunda kısa rapor. GATE dışında onay beklenmez.
