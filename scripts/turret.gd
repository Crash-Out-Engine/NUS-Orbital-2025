extends StaticBody2D

const BLEED_TIME = 0.125
const V_MODULATE = 100000000

var turret_active: bool
var player: Player

@onready var body_sprite = $Ranged/GunSprite


func _ready() -> void:
	$Ranged.active = false
	turret_active = false
	$BaseSprite.rotation = randf_range(0.0, 360.0)
	$Health.just_emptied.connect(die)
	$Health.just_reduced.connect(bleed)


func build() -> void:
	set_collidable(true)
	$Ranged.active = true
	turret_active = true
	set_visual_modulate(Color(1, 1, 1, 1))


func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)


func set_visual_modulate(color: Color) -> void:
	$BaseSprite.self_modulate = color
	$Ranged/GunSprite.self_modulate = color


func is_overlapping() -> bool:
	return $PlacementArea.get_overlapping_bodies().any(func(body): return body.get_node_or_null(^"Hitbox") != null)


func _process(delta: float) -> void:
	if (body_sprite.modulate.v > 1.0):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1.0):
			body_sprite.modulate.v = 1.0


func die():
	body_sprite.modulate.v = V_MODULATE
	if (player != null):
		player.turrets_placed -= 1
	queue_free()


func bleed(_amount: float):
	body_sprite.modulate.v = V_MODULATE
