class_name DalLevels
extends RefCounted
## Hand-placed greybox ponds. Difficulty: distance, rocks to bank around, fewer stones.

static func make(index: int) -> Dictionary:
	var L := [
		{"start": Vector2(360, 1000), "goal": Vector2(360, 380), "rocks": [], "stones": 6},
		{"start": Vector2(200, 1020), "goal": Vector2(520, 300), "rocks": [Rect2(250, 560, 220, 60)], "stones": 6},
		{"start": Vector2(360, 1050), "goal": Vector2(360, 230), "rocks": [Rect2(80, 640, 240, 50), Rect2(400, 640, 240, 50)], "stones": 6},
		{"start": Vector2(150, 1050), "goal": Vector2(570, 1050), "rocks": [Rect2(320, 600, 80, 670)], "stones": 7},
		{"start": Vector2(360, 1080), "goal": Vector2(150, 220), "rocks": [Rect2(16, 760, 420, 50), Rect2(280, 470, 430, 50)], "stones": 7},
		{"start": Vector2(600, 1080), "goal": Vector2(360, 640), "rocks": [Rect2(250, 520, 220, 40), Rect2(250, 720, 220, 40), Rect2(250, 520, 40, 240)], "stones": 6},
		{"start": Vector2(120, 1100), "goal": Vector2(600, 200), "rocks": [Rect2(16, 880, 520, 40), Rect2(180, 640, 520, 40), Rect2(16, 400, 520, 40)], "stones": 8},
		{"start": Vector2(360, 1100), "goal": Vector2(360, 200), "rocks": [Rect2(300, 300, 120, 700), Rect2(16, 500, 200, 40), Rect2(500, 760, 200, 40)], "stones": 7},
	]
	var d: Dictionary = L[index % L.size()].duplicate(true)
	d["index"] = index
	return d
