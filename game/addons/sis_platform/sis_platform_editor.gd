@tool
extends EditorPlugin
## Registers the Android export plugin that packages SisPlatform.aar and its
## Google dependencies (Gradle builds only) and injects the AdMob app id.

var _export: EditorExportPlugin

func _enter_tree() -> void:
	_export = SisPlatformExport.new()
	add_export_plugin(_export)

func _exit_tree() -> void:
	remove_export_plugin(_export)
	_export = null

class SisPlatformExport extends EditorExportPlugin:
	const DEPS := [
		"com.google.android.gms:play-services-ads:25.5.0",
		"com.google.android.ump:user-messaging-platform:4.0.0",
		"com.android.billingclient:billing:9.1.0",
		"com.google.android.play:review:2.0.2",
	]

	func _get_name() -> String:
		return "SisPlatform"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(["sis_platform/bin/SisPlatform-release.aar"])

	const FIREBASE_DEPS := ["com.google.firebase:firebase-analytics:24.0.0"]

	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var deps := PackedStringArray(DEPS)
		if PlatformConfig.load_config().firebase_enabled():
			deps.append_array(FIREBASE_DEPS)      # only packaged when configured
		return deps

	func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		var cfg := PlatformConfig.load_config()
		var xml := '<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="%s"/>\n' % cfg.admob_app_id
		if cfg.firebase_enabled():
			# nothing is collected until the consent flow finishes (Platform.gd enables it)
			xml += '<meta-data android:name="firebase_analytics_collection_enabled" android:value="false"/>\n'
		return xml
