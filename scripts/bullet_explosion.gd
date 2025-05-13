extends AnimatedSprite2D

func explode() -> void:
	play("default")
	$AudioStreamPlayer.play()
	await animation_finished
	queue_free()
	
