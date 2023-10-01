extends "res://scripts/Car.gd"

@export var max_steer_deg : float = 55.0

@onready var parking_detector_1 = $ParkingDetector1
@onready var parking_detector_2 = $ParkingDetector2
@onready var parking_detector_3 = $ParkingDetector3
@onready var parking_detector_4 = $ParkingDetector4
@onready var sprite = $Sprite2D

var level_manager : LevelManager

var mouse_active_timer : float = 0.0
const MOUSE_ACTIVE_TIME : float = 0.75
const MOUSE_STEER_TOLERANCE_DEG : float = 1.0

var in_target_space : bool = false
var parked_active_timer : float = 0.0
const PARKED_TIMER : float = 0.2

var has_won : bool = false
var has_won_active_timer : float = 0.0
var HAS_WON_TIMER : float = 2.0

func _ready():
	level_manager = get_node("/root/LevelManager")

func _process(delta : float) -> void:
	if has_won:
		has_won_active_timer += delta
		var scale = pow(1 + has_won_active_timer, 2)
		sprite.scale = Vector2(scale, scale)
		if has_won_active_timer > HAS_WON_TIMER:
			level_manager.change_level(level_manager.current_level + 1)
		return
	
	var mouse_steer := 0.0
	if mouse_active_timer > 0.0:
		mouse_active_timer -= delta
		var facing_dir := global_transform.x
		var target_dir := (get_global_mouse_position() - global_position).normalized()
		var angle_to := facing_dir.angle_to(target_dir)
		if angle_to > 0.5 * PI:
			angle_to = -angle_to + PI
		elif angle_to < -0.5 * PI:
			angle_to = -angle_to - PI
		mouse_steer = clampf(angle_to, -PI / 180 * max_steer_deg, PI / 180 * max_steer_deg)
	if abs(mouse_steer) < MOUSE_STEER_TOLERANCE_DEG * PI / 180:
		var steer_left := 1.0 if Input.is_action_pressed("steer_left") else 0.0
		var steer_right := 1.0 if Input.is_action_pressed("steer_right") else 0.0
		steer_left = maxf(steer_left, Input.get_action_strength("steer_left_analog"))
		steer_right = maxf(steer_right, Input.get_action_strength("steer_right_analog"))
		steer_angle = PI / 180 * max_steer_deg * (steer_right - steer_left)
	else:
		steer_angle = mouse_steer
	
	var drive_forward := 1.0 if Input.is_action_pressed("drive_forward") else 0.0
	var drive_reverse := 1.0 if Input.is_action_pressed("drive_reverse") else 0.0
	drive_forward = maxf(drive_forward, Input.get_action_strength("drive_forward_analog"))
	drive_reverse = maxf(drive_reverse, Input.get_action_strength("drive_reverse_analog"))
	drive_power = drive_forward - drive_reverse
	
	if in_target_space and linear_velocity.length() < 3 and angular_velocity < 1:
		parked_active_timer += delta
		if parked_active_timer > PARKED_TIMER:
			has_won = true
	else:
		parked_active_timer = 0.0
		

func _input(event : InputEvent) -> void:
	if event is InputEventMouse:
		mouse_active_timer = MOUSE_ACTIVE_TIME
		
func _on_parking_detector_entered(area: Area2D) -> void:
	var o1 = parking_detector_1.overlaps_area(area)
	var o2 = parking_detector_2.overlaps_area(area)
	var o3 = parking_detector_3.overlaps_area(area)
	var o4 = parking_detector_4.overlaps_area(area)
	in_target_space = o1 and o2 and o3 and o4
