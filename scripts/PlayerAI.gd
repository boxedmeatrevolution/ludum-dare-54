extends Node

const Car := preload("res://scripts/Car.gd")

@onready var parent : Car = get_parent()
@onready var win_sfx : AudioStreamPlayer = $WinSfx

var level_manager : LevelManager

var mouse_active_timer : float = 0.0
const MOUSE_ACTIVE_TIME : float = 0.75
const MOUSE_STEER_TOLERANCE_DEG : float = 1.0

var parking_detectors : Array[Area2D] = []
var parking_detector_triggered : Array[bool] = []
var in_target_space : bool = false
var parked_active_timer : float = 0.0
const PARKED_TIME : float = 0.2
const PARKING_DETECTOR_LAYER_NUMBER : int = 4

const LINEAR_VELOCITY_AT_REST_THRESHOLD : float = 3.0
const ANGULAR_VELOCITY_AT_REST_THRESHOLD : float = 0.05

var has_won : bool = false
var has_won_active_timer : float = 0.0
const HAS_WON_TIME : float = 2.0

var has_lost : bool = false
var has_lost_active_timer : float = 0.0
const HAS_LOST_TIME : float = 3.0

var headlights_on := false

func add_parking_detector(pos : Vector2) -> void:
	var idx := parking_detectors.size()
	var circle := CircleShape2D.new()
	circle.radius = 12
	var shape := CollisionShape2D.new()
	shape.shape = circle
	shape.position = Vector2.ZERO
	var area := Area2D.new()
	area.add_child(shape)
	area.position = pos
	area.set_collision_layer_value(1, false)
	area.set_collision_mask_value(PARKING_DETECTOR_LAYER_NUMBER, true)
	area.area_entered.connect(_on_parking_detector_entered.bind(idx))
	area.area_exited.connect(_on_parking_detector_exited.bind(idx))
	parent.add_child(area)
	parking_detectors.append(area)
	parking_detector_triggered.append(false)

func all_parking_detectors_triggered() -> bool:
	for p in parking_detector_triggered:
		if !p:
			return false
	return true

func _ready():
	assert(parent != null)
	level_manager = get_node("/root/LevelManager")

func _process(delta : float) -> void:
	if !headlights_on:
		headlights_on = true
		parent.sprite_headlight_left.visible = true
		parent.sprite_headlight_right.visible = true
	if parking_detectors.is_empty():
		var bound := parent.collision_shape.shape.get_rect()
		var x1 := bound.position.x
		var y1 := bound.position.y
		var x2 := bound.end.x
		var y2 := bound.end.y
		var transform := parent.collision_shape.transform
		add_parking_detector(transform * Vector2(x1, y1))
		add_parking_detector(transform * Vector2(x1, y2))
		add_parking_detector(transform * Vector2(x2, y1))
		add_parking_detector(transform * Vector2(x2, y2))
	
	if has_won:
		has_won_active_timer += delta
		var scale = pow(1 + has_won_active_timer, 2)
		parent.sprite.scale = Vector2(scale, scale)
		if has_won_active_timer > HAS_WON_TIME:
			level_manager.change_level(level_manager.current_level + 1)
	
	if has_lost:
		has_lost_active_timer += delta
		if has_lost_active_timer > HAS_LOST_TIME:
			level_manager.change_level(level_manager.current_level)
	
	if has_won || has_lost:
		parent.steer_angle = 0.0
		parent.drive_power = 0.0
		parent.brake = true
		parent.sprite_rearlight.visible = true
		return
	
	var mouse_steer := 0.0
	if mouse_active_timer > 0.0:
		mouse_active_timer -= delta
		var facing_dir := parent.global_transform.x
		var target_dir := (parent.get_global_mouse_position() - parent.global_position).normalized()
		var angle_to := facing_dir.angle_to(target_dir)
		if angle_to > 0.5 * PI:
			angle_to = -angle_to + PI
		elif angle_to < -0.5 * PI:
			angle_to = -angle_to - PI
		mouse_steer = clampf(angle_to, -PI / 180 * parent.max_steer_deg, PI / 180 * parent.max_steer_deg)
	if abs(mouse_steer) < MOUSE_STEER_TOLERANCE_DEG * PI / 180:
		var steer_left := 1.0 if Input.is_action_pressed("steer_left") else 0.0
		var steer_right := 1.0 if Input.is_action_pressed("steer_right") else 0.0
		steer_left = maxf(steer_left, Input.get_action_strength("steer_left_analog"))
		steer_right = maxf(steer_right, Input.get_action_strength("steer_right_analog"))
		parent.steer_angle = PI / 180 * parent.max_steer_deg * (steer_right - steer_left)
	else:
		parent.steer_angle = mouse_steer
	
	if Input.is_action_pressed("drive_mouse"):
		var facing_dir := parent.global_transform.x
		var target_dir := (parent.get_global_mouse_position() - parent.global_position).normalized()
		parent.drive_power = facing_dir.dot(target_dir)
	else:
		var drive_forward := 1.0 if Input.is_action_pressed("drive_forward") else 0.0
		var drive_reverse := 1.0 if Input.is_action_pressed("drive_reverse") else 0.0
		drive_forward = maxf(drive_forward, Input.get_action_strength("drive_forward_analog"))
		drive_reverse = maxf(drive_reverse, Input.get_action_strength("drive_reverse_analog"))
		parent.drive_power = drive_forward - drive_reverse
	if parent.drive_power < 0.0 || parent.brake == true:
		parent.sprite_rearlight.visible = true
	else:
		parent.sprite_rearlight.visible = false
	
	if Input.is_action_pressed("brake"):
		parent.brake = true
	else:
		parent.brake = false
	
	if all_parking_detectors_triggered() and parent.linear_velocity.length() < LINEAR_VELOCITY_AT_REST_THRESHOLD and parent.angular_velocity < ANGULAR_VELOCITY_AT_REST_THRESHOLD:
		parked_active_timer += delta
		if parked_active_timer > PARKED_TIME:
			win_sfx.play()
			has_won = true
	else:
		parked_active_timer = 0.0

func _input(event : InputEvent) -> void:
	if event is InputEventMouse:
		mouse_active_timer = MOUSE_ACTIVE_TIME

func _on_parking_detector_entered(_area: Area2D, idx : int) -> void:
	parking_detector_triggered[idx] = true
func _on_parking_detector_exited(_area: Area2D, idx : int) -> void:
	parking_detector_triggered[idx] = false
