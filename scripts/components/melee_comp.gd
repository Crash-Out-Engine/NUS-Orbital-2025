class_name MeleeComp
extends Area2D

signal executed(entity: Node2D)

@export var melee_cooldown: MeleeCooldownProp
@export var target_priority: TargetPriorityProp
@export var target_filter: TargetFilter
@export var effects: Array[EffectBase]


func _physics_process(_delta: float) -> void:
	if melee_cooldown.can_melee():
		for body in get_overlapping_bodies():
			if (body != null
					and body.get_node_or_null(^"Components/HitboxComp") != null
					and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
				melee_cooldown.do_melee()
				for effect in effects:
					body.get_node_or_null(^"Components/HitboxComp").trigger(effect, $"../../")
				executed.emit(body)
