extends StaticBody2D

@onready var ranged: Ranged = $Ranged

var target_provider: TargetProvider = null

func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)
