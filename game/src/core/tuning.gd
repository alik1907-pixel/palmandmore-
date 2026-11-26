class_name Tuning
extends Resource
## All balance values in one place (data/tuning.tres). Sim reads these; never hardcode.

@export_group("Body")
@export var nodes := 18
@export var node_radius := 4.0
@export var spring_k := 0.55
@export var pressure_k := 0.9
@export var damping := 0.992
@export var wall_friction_keep := 0.985
@export var lip_slip := 0.6            # px/iteration nudge off segment ends (no balancing on corners)

@export_group("Size")
@export var r_min := 22.0
@export var r_max := 70.0
@export var r_neutral := 42.0
@export var r_pop := 64.0
@export var pop_frames := 72
@export var inflate_rate := 70.0
@export var deflate_rate := 85.0

@export_group("Forces")
@export var gravity := 520.0
@export var buoyancy := 0.62
@export var air_drag_x := 1.6
@export var wind_scale := 0.62         # multiplies level wind strengths
@export var air_drag_y := 2.0          # vertical drag → terminal speed ~350 px/s when fully inflated
@export var sail_exponent := 2.0

@export_group("Rules")
@export var near_miss_px := 12.0
@export var hard_hit_speed := 220.0

static func load_default() -> Tuning:
	return load("res://data/tuning.tres") as Tuning
