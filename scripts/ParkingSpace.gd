@tool
extends Node2D

var car_types : Array = [
	preload("res://entities/cars/CarModelA.tscn"),
	preload("res://entities/cars/CarModelB.tscn"),
	preload("res://entities/cars/CarModelC.tscn"),
	preload("res://entities/cars/CarModelD.tscn"),
	preload("res://entities/cars/CarModelE.tscn"),
	preload("res://entities/cars/CarModelF.tscn"),
	preload("res://entities/cars/CarModelG.tscn")	
]

@export var spaces_wide: int:
	set(value):
		spaces_wide = value
		init()
@export var spaces_tall: int:
	set(value):
		spaces_tall = value
		init()
@export var space_width: int:
	set(value):
		space_width = value
		init()
@export var space_height: int:
	set(value):
		space_height = value
		init()
@export var fill_with_cars: bool:
	set(value):
		fill_with_cars = value
		init()
@export var instruction: Array[String]:
	set(value):
		instruction = value
		init()
@export var rng_seed: String:
	set(value):
		rng_seed = value
		init()

var lines: Array[Line2D] = []
var cars: Array[RigidBody2D] = []

var rng: RandomNumberGenerator


# Called when the node enters the scene tree for the first time.
func _ready():
	init()

func init():
	rng = RandomNumberGenerator.new()
	rng.seed = hash(rng_seed)
	init_lines()
	init_cars()

func init_cars():
	# destroy cars that already exist
	for car in cars:
		remove_child(car)
	cars = []
	
	if not fill_with_cars:
		return
		
	# custom car instructions
	var custom_instr_coords = []
	var custom_instr_values = []
	for instr in instruction:
		var parts = instr.rsplit(" ")
		if parts.size() == 3:
			custom_instr_coords.append(Vector2(int(parts[0]), int(parts[1])))
			custom_instr_values.append(int(parts[2]))
	
	# create cars
	for x in range(0, spaces_wide):
		for y in range(0, spaces_tall):
			var type_idx = rng.randi_range(0, car_types.size() - 1)
			var flipped = rng.randf() < 0.5
			
			var custom_instr_idx = custom_instr_coords.find(Vector2(x, y))
			if custom_instr_idx > -1:
				type_idx = custom_instr_values[custom_instr_idx]
				
			if type_idx < 0 or type_idx >= car_types.size():
				continue
			
			var car = car_types[type_idx].instantiate()
			car.position = Vector2(space_width * (x + 0.5), space_height * (y+0.5))
			car.rotation = PI / 2
			if flipped:
				car.rotation += PI
			cars.append(car)
	
	# add cars
	for car in cars:
		add_child(car)

func init_lines():
	# destroy lines that already exist
	for line in lines:
		remove_child(line)
	lines = []
	
	# create lines
	for x in range(0, spaces_wide):
		for y in range(0, spaces_tall):
			var offset = Vector2(x * space_width, y * space_height)
			var top_left = Vector2(0, 0) + offset
			var bottom_left = Vector2(0, space_height) + offset
			var bottom_right = Vector2(space_width, space_height) + offset
			var top_right = Vector2(space_width, 0) + offset
			
			if y == 0 || y < spaces_tall - 1:
				var line = Line2D.new()
				if x == 0: 
					line.add_point(top_left)
				line.add_point(bottom_left)
				line.add_point(bottom_right)
				line.add_point(top_right)
				lines.append(line)
			else:
				if x == 0:
					var left_line = Line2D.new()
					left_line.add_point(top_left)
					left_line.add_point(bottom_left)
					lines.append(left_line)
				var right_line = Line2D.new()
				right_line.add_point(top_right)
				right_line.add_point(bottom_right)
				lines.append(right_line)
	
	#add lines
	for line in lines:
		add_child(line)
