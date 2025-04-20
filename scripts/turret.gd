extends StaticBody2D

@onready var ranged: Ranged = $Ranged

var target_provider: TargetProvider = null

func _ready() -> void:
	ranged.active = true
	ranged.effect_mods.append_array([
		HealthEffect.create_instant(1.0),
	])

func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)
