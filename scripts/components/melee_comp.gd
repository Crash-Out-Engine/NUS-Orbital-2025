class_name MeleeComp
extends Area2D

signal executed(entity: Node2D)

@export var has_knockback: bool = false
@export var target_filter: TargetFilter
@export var effects: Array[Effect]

@export var entity: Node2D

@export var melee_cooldown: MeleeCooldownProp
@export var target_priority: TargetPriorityProp

func _physics_process(_delta: float) -> void:
	if melee_cooldown.can_melee():
		for body in get_overlapping_bodies():
			if (body != null
					and body.has_node(^"Components/HitboxComp")
					and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
				melee_cooldown.do_melee()
				if has_knockback:
					body.get_node(^"Components/HitboxComp").apply_knockback(global_position)
				body.get_node(^"Components/HitboxComp").trigger(effects, entity)
				executed.emit(body)
