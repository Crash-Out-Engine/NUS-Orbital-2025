extends AnimatedSprite2D


func explode() -> void:
	play("default")
	await animation_finished
	queue_free()
	
