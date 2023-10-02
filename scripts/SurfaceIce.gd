@tool
extends "res://scripts/Surface.gd"

const texture_ice_pebble := preload("res://sprites/TileIcePebble.png")
const texture_ice_smooth := preload("res://sprites/TileIceSmooth.png")

@export var smooth : bool = true:
	set(value):
		smooth = value
		if smooth:
			texture = texture_ice_smooth
		else:
			texture = texture_ice_pebble

func _ready() -> void:
	super()
	smooth = smooth
