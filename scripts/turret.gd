extends StaticBody2D

var target_provider: TargetProvider = null

func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)
