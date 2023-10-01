extends Area2D

@export var height : float = 1000.0
var direction : Vector2
var steepness : float

func _ready() -> void:
	steepness = height / abs(scale.y)
	direction = -global_transform.y
