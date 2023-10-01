extends Node

const Car := preload("res://scripts/Car.gd")

@export var target_speed : float = 500.0

@onready var parent : Car = get_parent()

var target_dir := Vector2.ZERO

const TARGET_ANGLE_TOLERANCE_DEG : float = 1.5

func _ready() -> void:
	assert(parent != null)
	parent.steer_angle = 0.0
	parent.drive_power = 0.0
	target_dir = parent.global_transform.x
	parent.linear_velocity = target_speed * target_dir

func _process(_delta : float) -> void:
	if parent.linear_velocity.length() < target_speed:
		parent.drive_power = 1.0
	else:
		parent.drive_power = 0.0
	
	var facing_dir := parent.global_transform.x
	var angle_to := facing_dir.angle_to(target_dir)
	if absf(angle_to) > PI / 180 * TARGET_ANGLE_TOLERANCE_DEG:
		parent.steer_angle = clampf(angle_to, -PI / 180 * parent.max_steer_deg, PI / 180 * parent.max_steer_deg)
