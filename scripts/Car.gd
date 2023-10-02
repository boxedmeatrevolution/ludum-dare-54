extends RigidBody2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var sprite_scratch : Sprite2D = $Sprite2DScratch

@onready var light_effect_parent : Node2D = get_node("/root/Level/LightParent")

@export var max_steer_deg : float = 55.0

@onready var sprite_headlight_left : Sprite2D = $Sprite2DHeadlightLeft
@onready var sprite_headlight_right : Sprite2D = $Sprite2DHeadlightRight
@onready var sprite_rearlight : Sprite2D = $Sprite2DRearlight

var steer_angle : float = 0.0
var drive_power : float = 0.0
var brake : bool = false
var wheel_count : int = 0

var damage : float = 0.0
var destroyed : bool = false
const DAMAGE_MIN_AMOUNT : float = 5.0
const DAMAGE_MAX_AMOUNT : float = 35.0
var previous_linear_velocity : Vector2 = Vector2.ZERO

signal damage_received(damage : float, total_damage : float, destroyed : bool)

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
		if damage > DAMAGE_MAX_AMOUNT && !destroyed:
			destroyed = true
			sprite_scratch.visible = true
		damage_received.emit(next_damage, damage, destroyed)
	previous_linear_velocity = linear_velocity

func _process(_delta : float) -> void:
	if !bounds.has_point(global_position):
		pass
