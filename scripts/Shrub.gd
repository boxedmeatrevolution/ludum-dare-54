extends StaticBody2D

@onready var sprite := $Sprite2D

@export var pot_type : int = 0

@onready var sprite_pot := $Sprite2DPot
@onready var sprite_pot_rocks := $Sprite2DPotRocks

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
	if pot_type == 0:
		pass
	elif pot_type == 1:
		sprite_pot.visible = true
	elif pot_type == 2:
		sprite_pot_rocks.visible = true
