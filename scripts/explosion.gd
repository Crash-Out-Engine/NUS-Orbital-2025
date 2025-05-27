class_name Explosion
extends Area2D

var team: String
var effects: Array[EffectBase] = []


func _enter_tree() -> void:
	call_deferred("explode")


func explode() -> void:
	$AnimatedSprite2D.play("default")
	$AudioStreamPlayer.play()
	
	var scene_tree = get_tree()
	await scene_tree.physics_frame
	await scene_tree.physics_frame
	#the node may move onto the next line before any physics frame has passed for this node to exist, thus two awaits are needed 
	for body in get_overlapping_bodies(): #the explosion should only check for and apply effects only once
		if body.get_node_or_null(^"Components/HitboxComp") != null and not body.is_in_group(team): # TODO: Don't rely on godot groups
			for effect in effects:
				body.get_node_or_null(^"Components/HitboxComp").trigger(effect)
	
	await $AnimatedSprite2D.animation_finished
	queue_free()
