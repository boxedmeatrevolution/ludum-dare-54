extends StaticBody2D

@onready var sprite := $Sprite2D

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
