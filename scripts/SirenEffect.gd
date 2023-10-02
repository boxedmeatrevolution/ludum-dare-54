extends Node2D

@onready var sprite := $Sprite2D

var car : Node2D = null
var timer := 0.0
const LIFETIME := 3.0

func _process(delta : float) -> void:
	if car != null:
		global_position = car.global_position
	sprite.rotation += 10.0 * delta
	sprite.scale *= exp(delta / 1.4)
	timer += delta / LIFETIME
	sprite.modulate.a = lerpf(1.0, 0.0, 0.5 * (1.0 - cos(PI * timer)))
	if timer > 1.0:
		queue_free()
