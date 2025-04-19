extends StaticBody2D

func set_collidable(value: bool) -> void:
	$"./CollisionShape2D".set_deferred("disabled", not value)
