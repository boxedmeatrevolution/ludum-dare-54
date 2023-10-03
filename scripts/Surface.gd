@tool
extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@export var texture : Texture2D:
	set(value):
		texture = value
		if sprite != null:
			init()
@export var mirrored : bool = false:
	set(value):
		mirrored = value
		if sprite != null:
			if value:
				sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
			else:
				sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
@export var centered : bool = false:
	set(value):
		centered = value
		if sprite != null:
			sprite.centered = centered

func init() -> void:
	if texture != null:
		sprite.texture = texture
		if mirrored:
			sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
		else:
			sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		sprite.centered = centered
		sprite.region_enabled = true
		sprite.region_rect.position = Vector2.ZERO
		sprite.region_rect.size.x = texture.get_width() * scale.x
		sprite.region_rect.size.y = texture.get_height() * scale.y
		sprite.scale.x = 1.0 / scale.x
		sprite.scale.y = 1.0 / scale.y

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		init()

func _ready() -> void:
	set_notify_transform(true)
	var old_mirrored := mirrored
	mirrored = false
	mirrored = true
	mirrored = old_mirrored
	centered = centered
	init()
