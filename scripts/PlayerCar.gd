extends "res://scripts/Car.gd"

@export var max_steer_deg : float = 55.0

func _process(delta : float) -> void:
	var steer_left := 1.0 if Input.is_action_pressed("steer_left") else 0.0
	var steer_right := 1.0 if Input.is_action_pressed("steer_right") else 0.0
	steer_left = maxf(steer_left, Input.get_action_strength("steer_left_analog"))
	steer_right = maxf(steer_right, Input.get_action_strength("steer_right_analog"))
	steer_angle = PI / 180 * max_steer_deg * (steer_right - steer_left)
	
	var drive_forward := 1.0 if Input.is_action_pressed("drive_forward") else 0.0
	var drive_reverse := 1.0 if Input.is_action_pressed("drive_reverse") else 0.0
	drive_forward = maxf(drive_forward, Input.get_action_strength("drive_forward_analog"))
	drive_reverse = maxf(drive_reverse, Input.get_action_strength("drive_reverse_analog"))
	drive_power = drive_forward - drive_reverse
