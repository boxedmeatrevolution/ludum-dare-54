extends Node2D

@export var bounds : Rect2 = Rect2(0.0, 0.0, 960.0, 600.0)
@export var target_path : NodePath
@export var position_time : float = 0.5

var target : RigidBody2D
var viewport : Viewport

var velocity_match : Vector2 = Vector2.ZERO
var velocity_match_time : float = 0.7

func clamp_position_in_bounds(p : Vector2) -> Vector2:
	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
			clampf(p.x, bounds.position.x + 0.5 * viewport_size.x, bounds.end.x - 0.5 * viewport_size.x),
			clampf(p.y, bounds.position.y + 0.5 * viewport_size.y, bounds.end.y - 0.5 * viewport_size.y)
		)

func _ready() -> void:
	if !target_path.is_empty():
		target = get_node(target_path)
	viewport = get_viewport()
	global_position = clamp_position_in_bounds(global_position)

func _process(delta : float) -> void:
	if target != null:
		var target_velocity := target.linear_velocity
		if target_velocity.length() > 300.0:
			target_velocity *= 300.0 / target_velocity.length()
		velocity_match = (velocity_match - target_velocity) * exp(-delta / velocity_match_time) + target_velocity
		var target_pos := clamp_position_in_bounds(target.global_position + velocity_match * 1.0)
		var current_pos := global_position
		global_position = (current_pos - target_pos) * exp(-delta / position_time) + target_pos
		global_position = clamp_position_in_bounds(global_position)
	viewport.canvas_transform = global_transform.inverse().translated(0.5 * viewport.get_visible_rect().size)
