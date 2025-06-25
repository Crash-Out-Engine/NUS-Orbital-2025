class_name MovementBaseComp
extends Node

# TODO: Integrate KnocbackResistanceProp into knockback calculations

@export var entity: RigidBody2D
@export var _knockback_speed_curve: Curve = Curve.new()
@export_group("Properties")
@export var _speed: SpeedProp
## Scales the displacement axis of the knockback speed curve.
@export var _knockback: KnockbackProp
## Scales the time axis of the knockback speed curve.
@export var _knockback_resistance: KnockbackResistanceProp

var movement_direction: Vector2
var active: bool = true
var _knockback_timer: float
var _knockback_duration: float
var _knockback_direction: Vector2
var _knockback_strength: float


func _ready() -> void:
	_knockback_duration = _knockback_speed_curve.get_domain_range()


func _physics_process(delta: float) -> void:
	if not active:
		entity.apply_central_impulse(entity.linear_velocity * entity.mass)
		return

	var movement_velocity := movement_direction * _speed.value
	var knockback_velocity := Vector2.ZERO
	if _knockback_timer > 0:
		knockback_velocity = (_knockback_direction
				* _knockback_speed_curve.sample(_knockback_duration - _knockback_timer)
				* _knockback_strength)
		_knockback_timer -= (
				delta * (_knockback_resistance.value if _knockback_resistance != null else 1.0))


	var net_velocity = movement_velocity + knockback_velocity

	entity.apply_central_impulse((net_velocity - entity.linear_velocity) * entity.mass)


func apply_knockback(direction: Vector2) -> void:
	_knockback_timer = _knockback_speed_curve.get_domain_range()
	_knockback_direction = direction
	_knockback_strength = _knockback.get_knockback() if _knockback != null else 0.0
