extends Node2D

@export var max_steer_deg : float = 0.0
@export var steer_time : float = 0.6
@export var drive_time : float = 0.05
@export var reset_time_factor : float = 4.0

@export var coeff_forward : float = 0.0
@export var coeff_reverse : float = 1.0
@export var curve_forward : Curve
@export var curve_reverse : Curve

@export var coeff_friction_parallel : float = 1.0
@export var coeff_friction_perpendicular : float = 1.0
@export var curve_friction_parallel : Curve
@export var curve_friction_perpendicular : Curve

@export var max_curve_velocity := 1000.0

@onready var parent : RigidBody2D = get_parent()

var steer_angle := 0.0
var drive_power := 0.0

func _ready() -> void:
	assert(parent != null)
	assert(parent.center_of_mass_mode == RigidBody2D.CENTER_OF_MASS_MODE_AUTO)

func _process(delta : float) -> void:
	var steer_left := 1.0 if Input.is_action_pressed("steer_left") else 0.0
	var steer_right := 1.0 if Input.is_action_pressed("steer_right") else 0.0
	steer_left = maxf(steer_left, Input.get_action_strength("steer_left_analog"))
	steer_right = maxf(steer_right, Input.get_action_strength("steer_right_analog"))
	var target_steer_angle := PI / 180 * max_steer_deg * (steer_right - steer_left)
	var true_steer_time := steer_time
	if abs(target_steer_angle) < abs(steer_angle):
		true_steer_time /= reset_time_factor
	steer_angle = (steer_angle - target_steer_angle) * exp(-delta / true_steer_time) + target_steer_angle
	
	var drive_forward := 1.0 if Input.is_action_pressed("drive_forward") else 0.0
	var drive_reverse := 1.0 if Input.is_action_pressed("drive_reverse") else 0.0
	drive_forward = maxf(drive_forward, Input.get_action_strength("drive_forward_analog"))
	drive_reverse = maxf(drive_reverse, Input.get_action_strength("drive_reverse_analog"))
	var target_drive_power = coeff_forward * drive_forward - coeff_reverse * drive_reverse
	var true_drive_time := steer_time
	if abs(target_drive_power) < abs(drive_power):
		true_drive_time /= reset_time_factor
	drive_power = (drive_power - target_drive_power) * exp(-delta / true_drive_time) + target_drive_power

func _physics_process(delta : float) -> void:
	# Velocity components relative to ground and orientation.
	var position_rel := global_position - parent.global_position
	var velocity_rel := -parent.angular_velocity * position_rel.orthogonal()
	var velocity := parent.linear_velocity + velocity_rel
	var forward_dir := parent.global_transform.x.rotated(steer_angle)
	var velocity_par := velocity.dot(forward_dir)
	var velocity_perp := velocity.cross(forward_dir)
	
	# Ground friction.
	if velocity_par != 0.0:
		var force_friction_par := -coeff_friction_parallel * curve_friction_parallel.sample(absf(velocity_par / max_curve_velocity)) * signf(velocity_par) * forward_dir
		parent.apply_force(force_friction_par, global_position - parent.global_position)
	if velocity_perp != 0.0:
		var force_friction_perp := -coeff_friction_perpendicular * curve_friction_perpendicular.sample(absf(velocity_perp / max_curve_velocity)) * signf(velocity_perp) * forward_dir.orthogonal()
		parent.apply_force(force_friction_perp, global_position - parent.global_position)
	
	# Acceleration and decceleration.
	if drive_power > 0.0:
		var force_forward := drive_power * curve_forward.sample(velocity_par / max_curve_velocity) * forward_dir
		parent.apply_force(force_forward, global_position - parent.global_position)
	elif drive_power < 0.0:
		var force_reverse := drive_power * curve_reverse.sample(-velocity_par / max_curve_velocity) * forward_dir
		parent.apply_force(force_reverse, global_position - parent.global_position)
