extends Sprite2D

var timer : float = 0.0
const TIME : float = 15.0

func _ready() -> void:
	modulate.a = 0.0

func _process(delta : float) -> void:
	if timer < TIME:
		timer += delta
	else:
		timer = TIME
	modulate.a = lerpf(0.0, 1.0, 0.5 * (1.0 - cos(PI * timer / TIME)))
