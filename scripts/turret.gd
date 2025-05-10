extends StaticBody2D

var turret_active

func _ready() -> void:
	$Ranged.active = false
	turret_active = false
	$BaseSprite.rotation = randf_range(0.0, 360.0)

func build() -> void:
	set_collidable(true)
	$Ranged.active = true
	turret_active = true
	set_visual_modulate(1, 1, 1, 1)

func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)

func set_visual_modulate(r: float, g: float, b: float, a: float) -> void:
	$BaseSprite.self_modulate.r = r
	$BaseSprite.self_modulate.g = g
	$BaseSprite.self_modulate.b = b
	$BaseSprite.self_modulate.a = a
	$Ranged/GunSprite.self_modulate.r = r
	$Ranged/GunSprite.self_modulate.g = g
	$Ranged/GunSprite.self_modulate.b = b
	$Ranged/GunSprite.self_modulate.a = a

func is_overlapping() -> bool:
	return $Area2D.get_overlapping_bodies().any(func (body): return body.get_node_or_null(^"Hitbox") != null)
