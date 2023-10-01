@tool
extends Node2D

@export var spaces_wide: int:
	set(value):
		spaces_wide = value
		init_lines()
@export var spaces_tall: int:
	set(value):
		spaces_tall = value
		init_lines()
@export var space_width: int:
	set(value):
		space_width = value
		init_lines()
@export var space_height: int:
	set(value):
		space_height = value
		init_lines()

var lines: Array[Line2D] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	init_lines()

func init_lines():
	# destroy any lines that already exist
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
