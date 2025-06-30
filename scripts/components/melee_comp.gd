class_name MeleeComp
extends Area2D

signal executed(entities: Array[Node2D])

@export_range(0, 100, 0.0001, "suffix:s") var delay: float = 0.0
@export var _automated: bool = true
@export var target_filter: TargetFilter
@export var _effects: Array[Effect]
@export var _entity: Node2D
@export var _melee_cooldown: MeleeCooldownProp


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if not _automated:
		return
	if _get_hittable_bodies().size() > 0:
		activate()


## Activates melee functionality.
##
## Can be called by other scripts to manually execute a melee attack.
func activate() -> void:
	if _melee_cooldown.can_melee():
		_melee_cooldown.do_melee()
		await get_tree().create_timer(delay).timeout
		var bodies = _get_hittable_bodies()
		for body in bodies:
			body.get_node(^"Components/HitboxComp").trigger(Attack.from(_entity, _effects))
			body.get_node(^"Components/HitboxComp").apply_knockback(global_position)
		executed.emit(bodies)


func _get_hittable_bodies() -> Array[Node2D]:
		return get_overlapping_bodies().filter(
				func(body):
					return (body != null
							and body.has_node(^"Components/HitboxComp")
							and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter))
		)
