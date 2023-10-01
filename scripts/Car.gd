extends RigidBody2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var steer_angle : float = 0.0
var drive_power : float = 0.0
var wheel_count : int = 0

var screen_size : Vector2

const OUT_OF_BOUNDS_PADDING : float = 128.0

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size

func _process(_delta : float) -> void:
	if global_position.x < -OUT_OF_BOUNDS_PADDING || global_position.y < -OUT_OF_BOUNDS_PADDING || global_position.x > screen_size.x + OUT_OF_BOUNDS_PADDING || global_position.y > screen_size.y + OUT_OF_BOUNDS_PADDING:
		queue_free()
