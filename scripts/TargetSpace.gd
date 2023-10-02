extends Node2D

@export var colour_closed : Color
@export var colour_open : Color
@export var colour_open_and_on : Color
@onready var sprite_text := $Sprite2DText
@onready var polygon := $ParkingSpacePoly
@onready var area := $ParkingArea
var text_initial_y : float
var timer : float = 0.0
const PERIOD : float = 2.0
var is_open : bool = false

const tex_closed := preload("res://sprites/TextNeedTicket.png")
const tex_open := preload("res://sprites/TextPark.png")

func _ready() -> void:
	sprite_text.texture = tex_closed
	polygon.color = colour_closed
	remove_child(area)
	sprite_text.global_transform = Transform2D.IDENTITY
	sprite_text.global_position = global_position + Vector2.UP * 32.0
	text_initial_y = sprite_text.global_position.y

func _process(delta : float) -> void:
	timer += delta
	sprite_text.global_position.y = text_initial_y + 16.0 * sin(2 * PI * timer / PERIOD)
	if timer > PERIOD:
		timer -= PERIOD

func ticket_collected() -> void:
	is_open = true
	sprite_text.texture = tex_open
	polygon.color = colour_open
	add_child(area)
	
func on() -> void:
	if is_open:
		polygon.color = colour_open_and_on
	else:
		polygon.color = colour_closed
		
func off() -> void:
	if is_open:
		polygon.color = colour_open
	else:
		polygon.color = colour_closed
	

