class_name Enemy
extends RigidBody2D

signal vfx_emitted(Node2D)

var loot_scene = preload("res://scenes/loot.tscn")

@onready var ranged: RangedAI = $Ranged


func _ready() -> void:
	$Health.just_emptied.connect(die)


func die():
	queue_free()
	
	var loot = loot_scene.instantiate()
	loot.global_position = global_position
	vfx_emitted.emit(loot)
