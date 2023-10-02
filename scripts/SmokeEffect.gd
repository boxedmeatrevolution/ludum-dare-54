extends Node2D

@onready var sprite := $AnimatedSprite2D
var velocity := Vector2.ZERO

func _ready() -> void:
	sprite.rotation = randf_range(-PI, PI)
	sprite.play("default")

func _process(delta : float) -> void:
	sprite.rotation += 1.0 * delta
	global_position += velocity * delta
	velocity *= exp(-delta / 2.0)

func _on_animation_finished() -> void:
	queue_free()
