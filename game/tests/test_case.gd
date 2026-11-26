class_name TestCase
extends RefCounted
## Minimal GUT-style base (GUT itself could not be downloaded in this environment).
## Test files: tests/test_*.gd, methods: test_*. Run: tools/run_tests.gd

var failures: Array[String] = []

func assert_true(cond: bool, msg := "") -> void:
	if not cond:
		failures.append("expected true: " + msg)

func assert_eq(a, b, msg := "") -> void:
	if a != b:
		failures.append("expected %s == %s %s" % [str(a), str(b), msg])

func assert_lt(a: float, b: float, msg := "") -> void:
	if not (a < b):
		failures.append("expected %s < %s %s" % [a, b, msg])
