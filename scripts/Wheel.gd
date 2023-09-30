extends Node2D

@export var max_steer_deg : float = 0.0

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

var force_list := PackedVector2Array()

func _ready() -> void:
	assert(parent != null)
	assert(parent.center_of_mass_mode == RigidBody2D.CENTER_OF_MASS_MODE_AUTO)

func _physics_process(delta : float) -> void:
	force_list.clear()
	
	# Velocity components relative to ground and orientation.
	var position_rel := global_position - parent.global_position
	var velocity_rel := -parent.angular_velocity * position_rel.orthogonal()
	var velocity := parent.linear_velocity + velocity_rel
	var steer_deg := max_steer_deg * (Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left"))
	var forward_dir := parent.global_transform.x.rotated(PI / 180 * steer_deg)
	var velocity_par := velocity.dot(forward_dir)
	var velocity_perp := velocity.cross(forward_dir)
	
	# Ground friction.
	if velocity_par != 0.0:
		var force_friction_par := -coeff_friction_parallel * curve_friction_parallel.sample(abs(velocity_par / max_curve_velocity)) * forward_dir
		if velocity_par < 0.0:
			force_friction_par *= -1.0
		parent.apply_force(force_friction_par, global_position - parent.global_position)
		force_list.append(force_friction_par)
	if velocity_perp != 0.0:
		var force_friction_perp := -coeff_friction_perpendicular * curve_friction_perpendicular.sample(abs(velocity_perp / max_curve_velocity)) * forward_dir.orthogonal()
		if velocity_perp < 0.0:
			force_friction_perp *= -1.0
		parent.apply_force(force_friction_perp, global_position - parent.global_position)
		force_list.append(force_friction_perp)
	
	# Acceleration and decceleration.
	var power_drive := coeff_forward * Input.get_action_strength("drive_forward") - coeff_reverse * Input.get_action_strength("drive_reverse")
	if power_drive > 0.0:
		var force_forward := power_drive * curve_forward.sample(velocity_par / max_curve_velocity) * forward_dir
		parent.apply_force(force_forward, global_position - parent.global_position)
		force_list.append(force_forward)
	elif power_drive < 0.0:
		var force_reverse := power_drive * curve_reverse.sample(-velocity_par / max_curve_velocity) * forward_dir
		parent.apply_force(force_reverse, global_position - parent.global_position)
		force_list.append(force_reverse)
	queue_redraw()

func _draw() -> void:
	#var xx := Vector2(parent.global_transform.x.x, parent.global_transform.y.x)
	#var yy := Vector2(parent.global_transform.x.y, parent.global_transform.y.y)
	#print(xx)
	#print(yy)
	draw_set_transform_matrix(get_global_transform().inverse())
	draw_line(global_position, global_position + 100 * parent.global_transform.x, Color.RED)
	draw_line(global_position, global_position + 100 * parent.global_transform.y, Color.BLUE)
	for force in force_list:
		draw_line(global_position, global_position + force, Color.ALICE_BLUE)
