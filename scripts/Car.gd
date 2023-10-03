extends RigidBody2D

const SmokeEffectScene := preload("res://entities/SmokeEffect.tscn")
const SmokeEffect := preload("res://scripts/SmokeEffect.gd")

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var sprite_scratch : Sprite2D = $Sprite2DScratch

@onready var light_parent : Node2D = get_node("/root/Level/LightParent")
@onready var effect_parent : Node2D = get_node("/root/Level/EffectParent")

@export var max_steer_deg : float = 55.0

@onready var sprite_headlight_left : Sprite2D = $Sprite2DHeadlightLeft
@onready var sprite_headlight_right : Sprite2D = $Sprite2DHeadlightRight
@onready var sprite_rearlight : Sprite2D = $Sprite2DRearlight

var steer_angle : float = 0.0
var drive_power : float = 0.0
var brake : bool = false
var wheel_count : int = 0

var can_despawn : bool = true
var was_in_bounds : bool = false

var damage : float = 0.0
var destroyed : bool = false
const DAMAGE_MIN_AMOUNT : float = 5.0
const DAMAGE_MAX_AMOUNT : float = 35.0
var previous_linear_velocity : Vector2 = Vector2.ZERO

var destroy_factor : float = 1.0

const SMOKE_TIME := 0.4
var smoke_timer := 0.0

signal damage_received(damage : float, total_damage : float, destroyed : bool)
signal out_of_bounds()

var bounds : Rect2 = Rect2(-INF, -INF, INF, INF)

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
	contact_monitor = true
	max_contacts_reported = 4

func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() > 0:
		var collision_impulse := (linear_velocity - previous_linear_velocity) / (state.inverse_mass * state.step)
		var next_damage = log(collision_impulse.length())
		if next_damage > DAMAGE_MIN_AMOUNT:
			damage += next_damage
			if smoke_timer <= 0.0:
				smoke_timer = SMOKE_TIME
				var num_smoke := 1
				for i in range(num_smoke):
					var big_smoke := SmokeEffectScene.instantiate()
					big_smoke.velocity = Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0))
					effect_parent.add_child(big_smoke)
					big_smoke.global_position = state.get_contact_collider_position(0) + Vector2(randf_range(-32.0, 32.0), randf_range(-32.0, 32.0))
					for j in range(2):
						var little_smoke := SmokeEffectScene.instantiate()
						little_smoke.velocity = big_smoke.velocity + Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0))
						effect_parent.add_child(little_smoke)
						little_smoke.global_position = big_smoke.global_position + Vector2(randf_range(-48.0, 48.0), randf_range(-48.0, 48.0))
						little_smoke.scale = Vector2(0.4, 0.4)
		if damage > destroy_factor * DAMAGE_MAX_AMOUNT && !destroyed:
			destroyed = true
			sprite_scratch.visible = true
		damage_received.emit(next_damage, damage, destroyed)
	previous_linear_velocity = linear_velocity

func _process(delta : float) -> void:
	if smoke_timer > 0.0:
		smoke_timer -= delta
	if !bounds.has_point(global_position):
		if was_in_bounds:
			if can_despawn:
				queue_free()
			out_of_bounds.emit()
	else:
		was_in_bounds = true
