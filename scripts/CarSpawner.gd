extends Node2D

const Car := preload("res://entities/cars/Car.tscn")
const DriverAI := preload("res://entities/DriverAI.tscn")
const LevelManager := preload("res://scripts/LevelManager.gd")

@export var initial_delay : float = 0.0
@export var interval : float = 5.0
@export var jitter : float = 0.0
@export var speed : float = 500.0

var car_parent : Node2D
var bounds : Rect2

var timer : float = 0.0

func _ready() -> void:
	timer = initial_delay

func _process(delta : float) -> void:
	timer -= delta
	if timer < 0.0:
		timer = interval * (1 + jitter * randf_range(-1.0, 1.0))
		var ai := DriverAI.instantiate()
		ai.target_speed = speed
		ai.target_dir = global_transform.x
		var car := Car.instantiate()
		car.add_child(ai)
		car_parent.add_child(car)
		car.global_transform = global_transform
		car.bounds = bounds
