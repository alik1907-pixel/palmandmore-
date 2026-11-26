class_name I18n
extends RefCounted
## UI strings for the 8 launch languages. Gameplay itself is wordless.
## Devanagari/Japanese glyphs come from the Android system font fallback.

const LANGS := ["tr", "en", "es", "pt", "id", "hi", "de", "ja"]

const S := {
	"play": {"tr": "OYNA", "en": "PLAY", "es": "JUGAR", "pt": "JOGAR", "id": "MAIN", "hi": "खेलें", "de": "SPIELEN", "ja": "プレイ"},
	"daily": {"tr": "Günlük Kuyu", "en": "Daily Shaft", "es": "Pozo diario", "pt": "Poço diário", "id": "Sumur Harian", "hi": "दैनिक कुआँ", "de": "Täglicher Schacht", "ja": "デイリー"},
	"daily_done": {"tr": "Bugünkü tamam!", "en": "Done for today!", "es": "¡Listo por hoy!", "pt": "Feito por hoje!", "id": "Selesai hari ini!", "hi": "आज का पूरा!", "de": "Heute geschafft!", "ja": "今日はクリア！"},
	"streak": {"tr": "seri", "en": "streak", "es": "racha", "pt": "sequência", "id": "beruntun", "hi": "लगातार", "de": "Serie", "ja": "連続"},
	"skins": {"tr": "Balonlar", "en": "Balloons", "es": "Globos", "pt": "Balões", "id": "Balon", "hi": "गुब्बारे", "de": "Ballons", "ja": "バルーン"},
	"themes": {"tr": "Temalar", "en": "Themes", "es": "Temas", "pt": "Temas", "id": "Tema", "hi": "थीम", "de": "Themen", "ja": "テーマ"},
	"settings": {"tr": "Ayarlar", "en": "Settings", "es": "Ajustes", "pt": "Ajustes", "id": "Pengaturan", "hi": "सेटिंग्स", "de": "Einstellungen", "ja": "設定"},
	"sound": {"tr": "Ses", "en": "Sound", "es": "Sonido", "pt": "Som", "id": "Suara", "hi": "ध्वनि", "de": "Ton", "ja": "効果音"},
	"music": {"tr": "Müzik", "en": "Music", "es": "Música", "pt": "Música", "id": "Musik", "hi": "संगीत", "de": "Musik", "ja": "音楽"},
	"haptics": {"tr": "Titreşim", "en": "Vibration", "es": "Vibración", "pt": "Vibração", "id": "Getar", "hi": "कंपन", "de": "Vibration", "ja": "振動"},
	"remove_ads": {"tr": "Reklamları kaldır", "en": "Remove ads", "es": "Quitar anuncios", "pt": "Remover anúncios", "id": "Hapus iklan", "hi": "विज्ञापन हटाएँ", "de": "Werbung entfernen", "ja": "広告を削除"},
	"theme_pack": {"tr": "Tüm temalar", "en": "All themes", "es": "Todos los temas", "pt": "Todos os temas", "id": "Semua tema", "hi": "सभी थीम", "de": "Alle Themen", "ja": "全テーマ"},
	"cosmetic_pack": {"tr": "Gökkuşağı balon", "en": "Rainbow balloon", "es": "Globo arcoíris", "pt": "Balão arco-íris", "id": "Balon pelangi", "hi": "इंद्रधनुष गुब्बारा", "de": "Regenbogenballon", "ja": "虹のバルーン"},
	"restore": {"tr": "Satın alımları geri yükle", "en": "Restore purchases", "es": "Restaurar compras", "pt": "Restaurar compras", "id": "Pulihkan pembelian", "hi": "खरीदारी बहाल करें", "de": "Käufe wiederherstellen", "ja": "購入を復元"},
	"privacy": {"tr": "Gizlilik seçenekleri", "en": "Privacy options", "es": "Opciones de privacidad", "pt": "Opções de privacidade", "id": "Opsi privasi", "hi": "गोपनीयता विकल्प", "de": "Datenschutzoptionen", "ja": "プライバシー設定"},
	"privacy_policy": {"tr": "Gizlilik politikası", "en": "Privacy policy", "es": "Política de privacidad", "pt": "Política de privacidade", "id": "Kebijakan privasi", "hi": "गोपनीयता नीति", "de": "Datenschutzerklärung", "ja": "プライバシーポリシー"},
	"patch": {"tr": "Yama ile devam", "en": "Patch & continue", "es": "Parchear y seguir", "pt": "Remendar e seguir", "id": "Tambal & lanjut", "hi": "पैच करके जारी रखें", "de": "Flicken & weiter", "ja": "パッチで続行"},
	"watch_unlock": {"tr": "Reklam izle, aç", "en": "Watch ad to unlock", "es": "Ver anuncio para desbloquear", "pt": "Assista para desbloquear", "id": "Tonton iklan untuk buka", "hi": "विज्ञापन देखकर खोलें", "de": "Werbung ansehen & freischalten", "ja": "広告を見て解放"},
	"new_unlock": {"tr": "Yeni!", "en": "New!", "es": "¡Nuevo!", "pt": "Novo!", "id": "Baru!", "hi": "नया!", "de": "Neu!", "ja": "新着！"},
	"share": {"tr": "Paylaş", "en": "Share", "es": "Compartir", "pt": "Compartilhar", "id": "Bagikan", "hi": "साझा करें", "de": "Teilen", "ja": "シェア"},
	"best": {"tr": "En iyi", "en": "Best", "es": "Mejor", "pt": "Melhor", "id": "Terbaik", "hi": "सर्वश्रेष्ठ", "de": "Bestzeit", "ja": "ベスト"},
	"language": {"tr": "Dil", "en": "Language", "es": "Idioma", "pt": "Idioma", "id": "Bahasa", "hi": "भाषा", "de": "Sprache", "ja": "言語"},
	"locked_stars": {"tr": "%d ★ gerekli", "en": "Needs %d ★", "es": "Requiere %d ★", "pt": "Requer %d ★", "id": "Butuh %d ★", "hi": "%d ★ चाहिए", "de": "Braucht %d ★", "ja": "★%d 必要"},
	"locked_streak": {"tr": "%d günlük seri", "en": "%d-day streak", "es": "Racha de %d días", "pt": "Sequência de %d dias", "id": "Beruntun %d hari", "hi": "%d दिन लगातार", "de": "%d-Tage-Serie", "ja": "%d日連続"},
	"share_daily": {"tr": "ŞİŞ Günlük #%d 🎈 %s sn %s 🔥%d", "en": "ŞİŞ Daily #%d 🎈 %ss %s 🔥%d", "es": "ŞİŞ Diario #%d 🎈 %ss %s 🔥%d", "pt": "ŞİŞ Diário #%d 🎈 %ss %s 🔥%d", "id": "ŞİŞ Harian #%d 🎈 %sd %s 🔥%d", "hi": "ŞİŞ दैनिक #%d 🎈 %s सेकंड %s 🔥%d", "de": "ŞİŞ Täglich #%d 🎈 %ss %s 🔥%d", "ja": "ŞİŞ デイリー #%d 🎈 %s秒 %s 🔥%d"},
	"share_level": {"tr": "ŞİŞ'te %d. bölümü %s sn'de geçtim %s Sen?", "en": "Beat ŞİŞ level %d in %ss %s Can you?", "es": "Pasé el nivel %d de ŞİŞ en %ss %s ¿Y tú?", "pt": "Passei o nível %d de ŞİŞ em %ss %s E você?", "id": "Lulus level %d ŞİŞ dalam %sd %s Kamu?", "hi": "ŞİŞ स्तर %d %s सेकंड में पूरा %s आप?", "de": "ŞİŞ Level %d in %ss geschafft %s Du?", "ja": "ŞİŞ レベル%dを%s秒でクリア %s 君は？"},
}

static var lang := ""

static func detect(chosen: String) -> void:
	if chosen in LANGS:
		lang = chosen
		return
	var sys := OS.get_locale_language()
	lang = sys if sys in LANGS else "en"

static func t(key: String) -> String:
	if lang == "":
		lang = "en"
	var row: Dictionary = S.get(key, {})
	return row.get(lang, row.get("en", key))

static func next_lang() -> String:
	var i := LANGS.find(lang)
	lang = LANGS[(i + 1) % LANGS.size()]
	return lang
