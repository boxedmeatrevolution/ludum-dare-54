extends StaticBody2D

@export var invert_polygon: bool
@export var invert_texture: bool
@export var texture: Texture2D

@onready var polygon = $Polygon2D
@onready var collision_polygon = $CollisionPolygon2D
@onready var line = $Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Invert curb?
	polygon.set_invert_enabled(invert_polygon);
	
	# Curb texture
	line.set_texture(texture)
	line.set_texture_mode(TEXTURE_REPEAT_ENABLED)
	if (invert_texture):
		# the reverse function doesn't work, so we do it manually
		var size = line.get_point_count()
		var copy = line.points.duplicate()
		for i in range(0, size):
			line.points[i].x = copy[size - 1 - i].x
			line.points[i].y = copy[size - 1 - i].y
	
	# Close the curb if not already closed
	var first_point = line.points[0]
	var last_point = line.points[line.get_point_count() - 1]
	if (first_point.distance_to(last_point) > 0):
		line.add_point(first_point)
	
	# Determine polygon shapes from the curb's line
	collision_polygon.polygon = line.points
	polygon.polygon = collision_polygon.polygon
	
	# Make the curb look closed
	line.add_point(line.points[1])
