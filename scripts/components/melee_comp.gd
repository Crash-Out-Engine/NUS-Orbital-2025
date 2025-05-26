class_name MeleeComp
extends Area2D

signal executed(entity: Node2D)

@export var melee_cooldown: MeleeCooldownProp
@export var target_priority: TargetPriorityProp
@export var effects: Array[EffectBase]

@onready var team: String = target_priority.team if target_priority != null else ""

func _on_body_entered(body: Node2D) -> void:
	if (body != null
			and body.get_node_or_null(^"Properties/TargetPriorityProp") != null
			and !body.get_node_or_null(^"Properties/TargetPriorityProp").team.is_empty()
			and body.get_node_or_null(^"Properties/TargetPriorityProp").team != team
			and body.get_node_or_null(^"Components/HitboxComp") != null
			and melee_cooldown.try_melee()):
		for effect in effects:
			body.get_node_or_null(^"Components/HitboxComp").trigger(effect, $"../../")
		executed.emit(body) # Replace with function body.
