extends "res://scripts/Car.gd"

@export var target_speed : float = 500.0

var target_dir := Vector2.ZERO

func _ready() -> void:
	steer_angle = 0.0
	drive_power = 0.0
	target_dir = global_transform.x
	linear_velocity = target_speed * target_dir

func _process(_delta : float) -> void:
	if linear_velocity.length() < target_speed:
		drive_power = 1.0
	else:
		drive_power = 0.0
	
	var facing_dir := global_transform.x
	var angle_to := facing_dir.angle_to(target_dir)
	if angle_to < 0.0:
		steer_angle = -1.0
	elif angle_to > 0.0:
		steer_angle = +1.0
