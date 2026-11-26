extends SceneTree
## Loads every script under res://src and res://tools to surface parse errors fast.
func _init() -> void:
	var bad := 0
	for dir in ["res://src", "res://tools", "res://tests"]:
		bad += _scan(dir)
	print("CHECK_DONE bad=%d" % bad)
	quit(1 if bad > 0 else 0)

func _scan(path: String) -> int:
	var bad := 0
	var d := DirAccess.open(path)
	if d == null:
		return 0
	for f in d.get_files():
		if f.ends_with(".gd"):
			var s = load(path + "/" + f)
			if s == null or not (s as GDScript).can_instantiate():
				print("BAD ", path + "/" + f)
				bad += 1
	for sub in d.get_directories():
		bad += _scan(path + "/" + sub)
	return bad
