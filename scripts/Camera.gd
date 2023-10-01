@tool
extends Node2D

@export var bounds : Rect2 = Rect2(0.0, 0.0, 960.0, 600.0):
	set(value):
		bounds = value
		queue_redraw()
	
@export var target_path : NodePath

@export var position_time : float = 0.5

var target : Node2D
var viewport : Viewport

func clamp_position_in_bounds(position : Vector2) -> Vector2:
	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
			clampf(position.x, bounds.position.x + 0.5 * viewport_size.x, bounds.end.x - 0.5 * viewport_size.x),
			clampf(position.y, bounds.position.y + 0.5 * viewport_size.y, bounds.end.y - 0.5 * viewport_size.y)
		)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	target = get_node(target_path)
	viewport = get_viewport()
	global_position = clamp_position_in_bounds(global_position)

func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
	if target != null:
		var target_pos := clamp_position_in_bounds(target.global_position)
		var current_pos := global_position
		global_position = (current_pos - target_pos) * exp(-delta / position_time) + target_pos
	viewport.canvas_transform = global_transform.inverse().translated(0.5 * viewport.get_visible_rect().size)

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(bounds, Color.BLUE, false, 10.0)
