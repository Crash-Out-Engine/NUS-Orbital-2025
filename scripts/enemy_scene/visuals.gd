class_name EnemyVisuals
extends Node2D

signal bleed_finished()

const BLEED_TIME = 0.04
const V_MODULATE = 100000000
const FLIP_THRESHOLD: float = 0.001

@export var enemy: Enemy
@export var health: HealthProp
@export var movement_comp: MovementBaseComp

@onready var body_sprite := $BodySprite as AnimatedSprite2D


func _ready() -> void:
	health.emptied.connect(
			func():
				if is_multiplayer_authority():
					_play_die_effect.rpc()
	)
	health.reduced.connect(
			func(_bleed):
				if is_multiplayer_authority():
					_play_bleed_effect.rpc())


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	# bleeding effect
	if (body_sprite.self_modulate.v > 1):
		body_sprite.self_modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.self_modulate.v <= 1):
			body_sprite.self_modulate.v = 1
			bleed_finished.emit()

	# sprite direction
	var x_velocity = movement_comp.movement_direction.x
	if absf(x_velocity) > FLIP_THRESHOLD:
		var flip_h = x_velocity < 0
		body_sprite.flip_h = flip_h


@rpc("any_peer", "call_local", "reliable")
func _play_die_effect():
	body_sprite.self_modulate.v = V_MODULATE


@rpc("any_peer", "call_local", "reliable")
func _play_bleed_effect():
	body_sprite.self_modulate.v = V_MODULATE
