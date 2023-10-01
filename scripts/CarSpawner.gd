extends Node2D

const DrivingCar := preload("res://entities/DrivingCar.tscn")

@export var initial_delay : float = 0.0
@export var interval : float = 5.0
@export var jitter : float = 0.0
@export var speed : float = 500.0

var timer : float = 0.0

func _ready() -> void:
	timer = initial_delay

func _process(delta : float) -> void:
	timer -= delta
	if timer < 0.0:
		timer = interval * (1 + jitter * randf_range(-1.0, 1.0))
		var car := DrivingCar.instantiate()
		add_child(car)
		car.global_transform = global_transform
