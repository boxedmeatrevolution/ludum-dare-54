extends Node2D

@onready var sprite_text := $Sprite2DText
var text_initial_y : float
var timer : float = 0.0
const PERIOD : float = 2.0

func _ready() -> void:
	sprite_text.global_transform = Transform2D.IDENTITY
	sprite_text.global_position = global_position + Vector2.UP * 32.0
	text_initial_y = sprite_text.global_position.y

func _process(delta : float) -> void:
	timer += delta
	sprite_text.global_position.y = text_initial_y + 16.0 * sin(2 * PI * timer / PERIOD)
	if timer > PERIOD:
		timer -= PERIOD
