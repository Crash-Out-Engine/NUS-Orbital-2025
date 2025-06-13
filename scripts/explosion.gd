class_name Explosion
extends Area2D

var target_filter: TargetFilter
var effects: Array[Effect] = []


func _enter_tree() -> void:
	call_deferred("explode")


func explode() -> void:
	if is_inside_tree():
		$AnimatedSprite2D.play("default")
		$AudioStreamPlayer.play()

		# The node should process overlapping bodies *after* a physics frame.
		# Note that overlapping bodies are only calculated during a physics frame.
		await get_tree().physics_frame

		# the explosion should only check for and apply effects only once
		for body in get_overlapping_bodies():
			if (body.has_node(^"Components/HitboxComp")
					and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
				body.get_node(^"Components/HitboxComp").trigger(effects, self)

		await $AnimatedSprite2D.animation_finished
		get_parent().remove_entity(self)

#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["target_filter"] = target_filter.save()
	dict["effects"] = Effect.save_array(effects)
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	target_filter = TargetFilter.from_saved(dict["target_filter"])
	effects = Effect.from_saved_array(dict["effects"])

#endregion
