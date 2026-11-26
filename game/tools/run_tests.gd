extends SceneTree
## Runs tests/test_*.gd. Exit code 0 = all green. Prints one line per test.
func _init() -> void:
	var total := 0
	var failed := 0
	var d := DirAccess.open("res://tests")
	var files := d.get_files()
	files.sort()
	for f in files:
		if not (f.begins_with("test_") and f.ends_with(".gd")) or f == "test_case.gd":
			continue
		var script: GDScript = load("res://tests/" + f)
		for m in script.get_script_method_list():
			var name: String = m.name
			if not name.begins_with("test_"):
				continue
			var inst = script.new()
			var t0 := Time.get_ticks_msec()
			inst.call(name)
			total += 1
			var ok: bool = inst.failures.is_empty()
			if not ok:
				failed += 1
			print("%s %s::%s (%d ms)" % ["PASS" if ok else "FAIL", f, name, Time.get_ticks_msec() - t0])
			for msg in inst.failures:
				print("      ", msg)
	print("TESTS: %d passed, %d failed" % [total - failed, failed])
	quit(1 if failed > 0 else 0)
