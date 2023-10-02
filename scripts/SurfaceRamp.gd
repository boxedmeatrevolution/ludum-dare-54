@tool
extends "res://scripts/Surface.gd"

const texture_ramp := preload("res://sprites/TileRamp.png")

@export var height : float = 400.0

func _ready() -> void:
	texture = texture_ramp
