extends StaticBody2D

func _ready() -> void:
	$Ranged.active = false
	$BaseSprite.rotation = randf_range(0.0, 360.0)

func build() -> void:
	set_collidable(true)
	$Ranged.active = true
	set_built_visual(true)

func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)

func set_built_visual(value: bool) -> void:
	$BaseSprite.self_modulate.a = 1 if value else 0.5
	$BaseSprite.self_modulate.r = 1 if value else 0
	$Ranged/GunSprite.self_modulate.a = 1 if value else 0.5
	$Ranged/GunSprite.self_modulate.r = 1 if value else 0
