extends Node

const Car = preload("res://scripts/Car.gd")

var car_parent_node: Node2D;
var level_manager : LevelManager


# Called when the node enters the scene tree for the first time.
func _ready():
	level_manager = get_node("/root/LevelManager")
	level_manager.set_level_node(self)
	
	# All cars belong to the car parent node
	car_parent_node = Node2D.new()
	var cars = []
	for child in get_children():
		if (child is Car):
			cars.append(child)
	for car in cars:
		remove_child(car)
		car_parent_node.add_child(car)
	add_child(car_parent_node)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
