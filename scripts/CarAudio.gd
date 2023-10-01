extends Node2D

const Car := preload("res://scripts/Car.gd")
const Wheel := preload("res://scripts/Wheel.gd")

@onready var parent : Car = get_parent()
@onready var wheel1 : Wheel = parent.find_child("Wheel1")
@onready var wheel2 : Wheel = parent.find_child("Wheel2")
@onready var wheel3 : Wheel = parent.find_child("Wheel3")
@onready var wheel4 : Wheel = parent.find_child("Wheel4")

@onready var engine_idle : AudioStreamPlayer2D = $EngineIdle
@onready var engine_up : AudioStreamPlayer2D = $EngineUp #Stream length should be the same as EngineDown
@onready var engine_high : AudioStreamPlayer2D = $EngineHigh
@onready var engine_down : AudioStreamPlayer2D = $EngineDown

@onready var drift_enter : AudioStreamPlayer2D = $DriftEnter
@onready var drifting : AudioStreamPlayer2D = $Drifting
@onready var drift_exit : AudioStreamPlayer2D = $DriftExit

enum {DRIFT_OFF, DRIFT_ENTER, DRIFT_ON, DRIFT_EXIT}
enum {ENGINE_OFF, ENGINE_IDLE, ENGINE_UP, ENGINE_HIGH, ENGINE_DOWN}

var drift_state = DRIFT_OFF
var engine_state = ENGINE_OFF

var sound_loop_offset = 0

func clear_all_signal_connections(sig : Signal):
	for connection in sig.get_connections():
		sig.disconnect(connection.callable)

func update_engine_state(drive_power, engine_up_finished, engine_down_finished):
	match engine_state:
		ENGINE_OFF, ENGINE_IDLE:
			if drive_power:
				engine_idle.stop()
				engine_up.play()
				engine_up.finished.connect(func(): update_engine_state(drive_power, true, false))
				engine_state = ENGINE_UP
		ENGINE_UP:
			if engine_up_finished:
				clear_all_signal_connections(engine_up.finished)
				engine_high.play(engine_high.stream.get_length() * sound_loop_offset)
				engine_state = ENGINE_HIGH
			elif not drive_power:
				var engine_up_offset = engine_up.get_playback_position()
				engine_up.stop()
				engine_down.play(engine_down.stream.get_length() - engine_up_offset)
				engine_down.finished.connect(func(): update_engine_state(drive_power, false, true))
				engine_state = ENGINE_DOWN
		ENGINE_HIGH:
			if not drive_power:
				engine_high.stop()
				engine_down.play()
				engine_down.finished.connect(func(): update_engine_state(drive_power, false, true))
				engine_state = ENGINE_DOWN
		ENGINE_DOWN:
			if engine_down_finished:
				clear_all_signal_connections(engine_down.finished)
				engine_idle.play(engine_idle.stream.get_length() * sound_loop_offset)
				engine_state = ENGINE_IDLE
			elif drive_power:
				var engine_down_offset = engine_down.get_playback_position()
				engine_down.stop()
				engine_up.play(engine_up.stream.get_length() - engine_down_offset)
				engine_up.finished.connect(func(): update_engine_state(drive_power, true, false))
				engine_state = ENGINE_UP
		_:
			print("CarAudio: Error!!! Unknown engine state.")


const DRIFT_ANGULAR_THRESHOLD = 3
const DRIFT_LINEAR_THRESHOLD = 500
func calculate_drift():
	var angular_velocity = abs(parent.angular_velocity)
	var linear_velocity = parent.linear_velocity
	if angular_velocity > DRIFT_ANGULAR_THRESHOLD and linear_velocity.length() < DRIFT_LINEAR_THRESHOLD:
		return 1
	return 0


func update_drift_state(drift_amount, drift_enter_finished, drift_exit_finished):
	match drift_state:
		DRIFT_OFF:
			if drift_amount:
				drift_enter.play()
				drift_enter.finished.connect(func(): update_drift_state(drift_amount, true, false))
				drift_state = DRIFT_ENTER
		DRIFT_ENTER:
			if drift_enter_finished:
				clear_all_signal_connections(drift_enter.finished)
				drifting.play()
				drift_state = DRIFT_ON
			elif not drift_amount:
				clear_all_signal_connections(drift_enter.finished)
				drift_enter.stop()
				drift_exit.play()
				drift_exit.finished.connect(func(): update_drift_state(drift_amount, false, true))
				drift_state = DRIFT_EXIT
		DRIFT_ON:
			if not drift_amount:
				drifting.stop()
				drift_exit.play()
				drift_exit.finished.connect(func(): update_drift_state(drift_amount, false, true))
				drift_state = DRIFT_EXIT
		DRIFT_EXIT:
			if drift_exit_finished:
				clear_all_signal_connections(drift_exit.finished)
				drift_state = DRIFT_OFF
		_:
			print("CarAudio: Error!!! Unknown drift state.")


func _ready():
	var rng = RandomNumberGenerator.new()
	sound_loop_offset = rng.randf()


func _process(delta):
	update_engine_state(parent.drive_power, false, false)
	update_drift_state(calculate_drift(), false, false)
