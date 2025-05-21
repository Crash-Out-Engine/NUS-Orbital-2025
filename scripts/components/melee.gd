class_name Melee
extends Area2D

signal executed(entity: Node2D)

@export var melee_cooldown: MeleeCooldown
@export var melee_damage: MeleeDamage

@onready var team: String = $"../TargetPriority".team if $"../TargetPriority" != null else ""

func _on_body_entered(body: Node2D) -> void:
	if (body != null
			and body.get_node_or_null(^"TargetPriority") != null
			and !body.get_node_or_null(^"TargetPriority").team.is_empty()
			and body.get_node_or_null(^"TargetPriority").team != team
			and body.get_node_or_null(^"./Hitbox") != null
			and melee_cooldown.try_melee()):
		body.get_node_or_null(^"./Hitbox").trigger(melee_damage.get_effect(), get_parent())
		executed.emit(body) # Replace with function body.
