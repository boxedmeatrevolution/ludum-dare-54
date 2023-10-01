extends Node2D

const Car := preload("res://scripts/Car.gd")
const Ramp := preload("res://scripts/Ramp.gd")

@export var coeff_steer : float = 0.0
@export var steer_time : float = 0.6
@export var drive_time : float = 0.05
@export var reset_time_factor : float = 4.0

@export var coeff_forward : float = 0.0
@export var coeff_reverse : float = 0.0
@export var curve_forward : Curve
@export var curve_reverse : Curve

@export var coeff_friction_parallel : float = 1.0
@export var coeff_friction_perpendicular : float = 1.0
@export var curve_friction_parallel : Curve
@export var curve_friction_perpendicular : Curve

@export var coeff_brake : float = 1.0
@export var curve_brake : Curve
@export var curve_brake_slip : Curve

@export var max_curve_velocity : float = 1000.0

@onready var parent : Car = get_parent()

var steer_angle := 0.0
var drive_power := 0.0
var current_ramp : Ramp = null

const FORWARD_SPEED_THRESHOLD : float = 2.0
const REVERSE_SPEED_THRESHOLD : float = 2.0

var BRAKE_LOCK_TIME : float = 0.12
var brake_lock_timer : float = 0.0

func _ready() -> void:
	assert(parent != null)
	assert(parent.center_of_mass_mode == RigidBody2D.CENTER_OF_MASS_MODE_AUTO)
	parent.wheel_count += 1

func _process(delta : float) -> void:
	var true_steer_time := steer_time
	var target_steer_angle := coeff_steer * parent.steer_angle
	if abs(target_steer_angle) < abs(steer_angle):
		true_steer_time /= reset_time_factor
	steer_angle = (steer_angle - target_steer_angle) * exp(-delta / true_steer_time) + target_steer_angle
	
	var target_drive_power := coeff_forward * parent.drive_power if parent.drive_power > 0.0 else coeff_reverse * parent.drive_power
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
	var parent_velocity_par := parent.linear_velocity.dot(parent.global_transform.x)
	
	if parent.brake || (drive_power > 0.0 && parent_velocity_par < -FORWARD_SPEED_THRESHOLD) || (drive_power < 0.0 && parent_velocity_par > REVERSE_SPEED_THRESHOLD):
		brake_lock_timer = BRAKE_LOCK_TIME
	var is_braking := false
	if brake_lock_timer > 0.0:
		brake_lock_timer -= delta
		is_braking = true
	
	# Ground friction.
	if velocity_par != 0.0:
		var force_friction_par := -coeff_friction_parallel * curve_friction_parallel.sample(absf(velocity_par / max_curve_velocity)) * signf(velocity_par) * forward_dir
		if is_braking:
			force_friction_par += -coeff_brake * curve_brake.sample(absf(velocity_par / max_curve_velocity)) * signf(velocity_par) * forward_dir
		parent.apply_force(force_friction_par, global_position - parent.global_position)
	if velocity_perp != 0.0:
		var force_friction_perp := -coeff_friction_perpendicular * curve_friction_perpendicular.sample(absf(velocity_perp / max_curve_velocity)) * signf(velocity_perp) * forward_dir.orthogonal()
		if is_braking:
			force_friction_perp *= 1.0 - coeff_brake * curve_brake_slip.sample(absf(velocity_perp) / max_curve_velocity)
		parent.apply_force(force_friction_perp, global_position - parent.global_position)
	
	# Acceleration and decceleration.
	if drive_power > 0.0 && !is_braking:
		var force_forward := drive_power * curve_forward.sample(velocity_par / max_curve_velocity) * forward_dir
		parent.apply_force(force_forward, global_position - parent.global_position)
	elif drive_power < 0.0 && !is_braking:
		var force_reverse := drive_power * curve_reverse.sample(-velocity_par / max_curve_velocity) * forward_dir
		parent.apply_force(force_reverse, global_position - parent.global_position)
	
	# Rolling down ramps.
	if current_ramp != null:
		var force_gravity := parent.mass / parent.wheel_count * current_ramp.steepness * current_ramp.direction.dot(forward_dir) * forward_dir
		parent.apply_force(force_gravity, global_position - parent.global_position)

func _on_ramp_entered(area : Area2D) -> void:
	current_ramp = area as Ramp

func _on_ramp_exited(_area : Area2D) -> void:
	current_ramp = null
