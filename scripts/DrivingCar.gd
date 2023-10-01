extends "res://scripts/Car.gd"

@export var target_speed : float = 500.0

var target_dir := Vector2.ZERO
var screen_size : Vector2
const OUT_OF_BOUNDS_PADDING : float = 128.0
const TARGET_ANGLE_TOLERANCE : float = 0.01

func _ready() -> void:
	steer_angle = 0.0
	drive_power = 0.0
	target_dir = global_transform.x
	linear_velocity = target_speed * target_dir
	screen_size = get_viewport().get_visible_rect().size

func _process(_delta : float) -> void:
	if linear_velocity.length() < target_speed:
		drive_power = 1.0
	else:
		drive_power = 0.0
	
	var facing_dir := global_transform.x
	var angle_to := facing_dir.angle_to(target_dir)
	if angle_to < -TARGET_ANGLE_TOLERANCE:
		steer_angle = -1.0
	elif angle_to > TARGET_ANGLE_TOLERANCE:
		steer_angle = 1.0
	
	if global_position.x < -OUT_OF_BOUNDS_PADDING || global_position.y < -OUT_OF_BOUNDS_PADDING || global_position.x > screen_size.x + OUT_OF_BOUNDS_PADDING || global_position.y > screen_size.y + OUT_OF_BOUNDS_PADDING:
		queue_free()
