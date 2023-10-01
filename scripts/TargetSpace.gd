@tool
extends Node

@export var width: float:
	set(value):
		width = value
		_init_space()
@export var height: float:
	set(value):
		height = value
		_init_space()

@onready var parking_poly = $ParkingSpacePoly
@onready var parking_area_collision = $ParkingArea/ParkingAreaCollision


# Called when the node enters the scene tree for the first time.
func _ready():
	_init_space();
	
func _init_space():
	if parking_poly == null:
		return
		
	# Corners
	var top_left = Vector2(0, 0)
	var top_right = Vector2(width, 0)
	var bottom_right = Vector2(width, height)
	var bottom_left = Vector2(0, height)
	
	# Visuals
	parking_poly.set_polygon(
		PackedVector2Array([top_left, top_right, bottom_right, bottom_left])
	)
	
	# Collisions
	parking_area_collision.shape.size = Vector2(width, height)
	parking_area_collision.position = Vector2(width/2, height/2)
