extends Node2D

@onready var sprite := $Sprite2D
@onready var area := $Area2D
@onready var winfx := $WinSfx
var timer : float = 0.0
const PERIOD : float = 4.0

var dead : bool = false
var death_timer : float = 0.0
const DEATH_TIME : float = 0.4

signal ticket_collected()

func _process(delta : float) -> void:
	timer += delta
	if timer > PERIOD:
		timer -= PERIOD
	sprite.position.y = 8.0 * sin(4 * PI * timer / PERIOD)
	sprite.rotation = 0.2 * cos(2 * PI * timer / PERIOD)
	if dead:
		death_timer += delta
		if death_timer > DEATH_TIME:
			queue_free()
		scale = lerpf(1.0, 0.0, death_timer / DEATH_TIME) * Vector2(1.0, 1.0)
		rotation += 2.0 * delta


func _on_player_area_entered(area : Area2D) -> void:
	if !dead:
		ticket_collected.emit()
		dead = true
		winfx.play()
		area.queue_free()
