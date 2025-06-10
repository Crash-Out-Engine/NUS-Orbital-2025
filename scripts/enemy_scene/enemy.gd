class_name Enemy
extends RigidBody2D

signal vfx_emitted(Node2D)

const _LOOT_SCENE = preload("res://scenes/loot.tscn")

@export var health_prop: HealthProp
@export var movement_prop: MovementProp

@onready var visuals := $Visuals as EnemyVisuals


func _ready() -> void:
	health_prop.emptied.connect(die)

func die():
	await visuals.bleed_finished
	queue_free()

	var loot = _LOOT_SCENE.instantiate()
	loot.setup_scrap_loot(1)
	loot.global_position = global_position
	vfx_emitted.emit(loot)

func deactivate():
	movement_prop.active = false
	linear_velocity = Vector2(0, 0)
