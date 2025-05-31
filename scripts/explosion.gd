class_name Explosion
extends Area2D

var target_filter: TargetFilter
var effects: Array[EffectBase] = []


func _enter_tree() -> void:
	call_deferred("explode")


func explode() -> void:
	$AnimatedSprite2D.play("default")
	$AudioStreamPlayer.play()
	
	# The node should process overlapping bodies *after* a physics frame.
	# Note that overlapping bodies are only calculated during a physics frame.
	await get_tree().physics_frame 
	
	for body in get_overlapping_bodies(): # the explosion should only check for and apply effects only once
		if (body.get_node_or_null(^"Components/HitboxComp") != null
				and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
			for effect in effects:
				body.get_node_or_null(^"Components/HitboxComp").trigger(effect)
	
	await $AnimatedSprite2D.animation_finished
	queue_free()
