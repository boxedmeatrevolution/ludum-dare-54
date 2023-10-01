extends RigidBody2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D

@export var max_steer_deg : float = 55.0

var steer_angle : float = 0.0
var drive_power : float = 0.0
var brake : bool = false
var wheel_count : int = 0

var damage : float = 0.0
const DAMAGE_THRESHOLD : float = 5.0
var previous_linear_velocity : Vector2 = Vector2.ZERO

signal damage_received(total_damage : float)

var bounds : Rect2 = Rect2(-INF, -INF, INF, INF)

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
	contact_monitor = true
	max_contacts_reported = 10

func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() > 0:
		var collision_impulse := (linear_velocity - previous_linear_velocity) / (state.inverse_mass * state.step)
		var next_damage = log(collision_impulse.length())
		if next_damage > DAMAGE_THRESHOLD:
			damage += next_damage
			damage_received.emit(damage)
	previous_linear_velocity = linear_velocity

func _process(_delta : float) -> void:
	if !bounds.has_point(global_position):
		pass
