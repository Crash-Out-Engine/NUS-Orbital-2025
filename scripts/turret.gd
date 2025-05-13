extends StaticBody2D

var turret_active
@onready var body_sprite = $Ranged/GunSprite
var player: Player

const BLEED_TIME = 0.125
const V_MODULATE = 100000000

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

func _process(delta: float) -> void:
	if(body_sprite.modulate.v > 1):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if(body_sprite.modulate.v <= 1):
			body_sprite.modulate.v = 1

func die():
	body_sprite.modulate.v = V_MODULATE
	if(player != null):
		player.turrets_placed -= 1
	queue_free()

func bleed(_amount: float):
	body_sprite.modulate.v = V_MODULATE
