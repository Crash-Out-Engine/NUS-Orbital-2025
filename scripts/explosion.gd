class_name Explosion
extends Area2D

var team: String
var effects: Array[Effect] = []

func explode() -> void:
	$AnimatedSprite2D.play("default")
	$AudioStreamPlayer.play()
	
	var scene_tree = get_tree()
	await scene_tree.physics_frame
	await scene_tree.physics_frame
	#the node may move onto the next line before any physics frame has passed for this node to exist, thus two awaits are needed 
	for body in get_overlapping_bodies(): #the explosion should only check for and apply effects only once
		if body.get_node_or_null(^"./Hitbox") != null and not body.is_in_group(team): # TODO: Don't rely on godot groups
			for effect in effects:
				body.get_node_or_null(^"./Hitbox").trigger(effect)
	
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
