class_name Melee
extends Node

signal executed(entity: Node2D)

@export var melee_cooldown: MeleeCooldown
@export var melee_damage: MeleeDamage

@onready var team: String = $"../TargetPriority".team if $"../TargetPriority" != null else ""


func _ready() -> void:
	assert(get_parent() is RigidBody2D, "Parent should be a RigidBody2D.")
	

func _physics_process(_delta: float) -> void:
	for collider in get_parent().get_colliding_bodies():
		if (collider != null
				and collider.get_node_or_null(^"TargetPriority") != null
				and !collider.get_node_or_null(^"TargetPriority").team.is_empty()
				and collider.get_node_or_null(^"TargetPriority").team != team
				and collider.get_node_or_null(^"./Hitbox") != null
				and melee_cooldown.try_melee()):
			collider.get_node_or_null(^"./Hitbox").trigger(melee_damage.get_effect(), get_parent())
			executed.emit(collider)
