class_name HitboxComp
extends Node

signal hit_by(attack: Attack)

@export var _entity: Node2D
@export var team: Enums.Team

@export_group("Components")
@export var movement: MovementBaseComp

var _effect_signatures: Dictionary[PackedByteArray, Effect.LingeringTimer]


func trigger(attack: Attack) -> void:
	_auth_trigger.rpc_id(
			get_multiplayer_authority(), attack.save())


func is_targeted_by(target_filter: TargetFilter):
	return team in target_filter.targets


func apply_knockback(from: Vector2) -> void:
	if movement != null:
		movement.apply_knockback(from.direction_to(_entity.global_position))


static func make_effect_signature(effect: Effect, entity: Node2D) -> PackedByteArray:
	var effect_data := effect.save()
	var entity_id := entity.get_instance_id()
	return var_to_bytes([effect_data, entity_id])


#region Authority

@rpc("any_peer", "call_local", "reliable")
func _auth_trigger(attack_data: PackedByteArray) -> void:
	if not is_multiplayer_authority():
		return

	var attack := Attack.from_saved(attack_data)

	for effect in attack.effects:
		for prop_node in $"../../Properties".get_children():
			var lingering := effect.apply_effect(prop_node)
			if lingering != null and _entity != null:
				var signature := make_effect_signature(effect, _entity)

				# Disable previous lingering effect and add new lingering effect
				if signature in _effect_signatures and _effect_signatures[signature] != null:
					_effect_signatures[signature].disable()
				_effect_signatures.set(signature, lingering)

	# Clear freed lingering effects
	for signature in _effect_signatures:
		if _effect_signatures[signature] == null:
			_effect_signatures.erase(signature)

	hit_by.emit(attack)

#endregion
