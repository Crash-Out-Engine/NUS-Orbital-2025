class_name Enemy
extends RigidBody2D

signal vfx_emitted(Node2D)

@export var health_prop: HealthProp

var loot_scene = preload("res://scenes/loot.tscn")


func _ready() -> void:
	health_prop.just_emptied.connect(die)


func die():
	queue_free()
	
	var loot = loot_scene.instantiate()
	loot.global_position = global_position
	vfx_emitted.emit(loot)
