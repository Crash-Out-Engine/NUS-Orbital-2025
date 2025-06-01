extends Node2D

const BLEED_TIME = 0.125
const V_MODULATE = 100000000

@export var turret: Turret
@export var turret_ranged: RangedBaseComp
@export var turret_health: HealthProp

@onready var base_sprite := $BaseSprite as Sprite2D
@onready var body_sprite := $BodySprite as AnimatedSprite2D


func _ready() -> void:
	turret_ranged.bullet_spawned.connect(func(_bullet): play_fire_anim())
	turret_health.just_reduced.connect(func(_amount): bleed())
	turret.state_changed.connect(handle_state_changed)
	base_sprite.rotation = randf_range(0.0, 360.0)


func _process(delta: float) -> void:
	# Animation & transform
	if !body_sprite.is_playing():
		play_idle_anim()
	body_sprite.transform = body_sprite.transform.rotated(
			turret_ranged.transform.get_rotation() - body_sprite.transform.get_rotation())

	# Modulate effect
	if (body_sprite.modulate.v > 1.0):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1.0):
			body_sprite.modulate.v = 1.0


func handle_state_changed(from: Turret.State, to: Turret.State) -> void:
	match [from, to]:
		[_, Turret.State.PLACING]:
			set_visual_modulate(Color(0, 1, 1, 0.5))

		[_, Turret.State.PLANNED]:
			set_visual_modulate(Color(1, 1, 1, 0.1))

		[_, Turret.State.BUILDING]:
			set_visual_modulate(Color(1, 1, 1, 0.5))

		[_, Turret.State.OPERATIONAL]:
			set_visual_modulate(Color(1, 1, 1, 1))


func play_idle_anim() -> void:
	body_sprite.play("idle")


func play_fire_anim() -> void:
	body_sprite.sprite_frames.set_animation_speed("fire", 4.0 / turret_ranged.ranged_cooldown.value)
	body_sprite.play("fire")


func set_visual_modulate(color: Color) -> void:
	base_sprite.self_modulate = color
	body_sprite.self_modulate = color


func bleed() -> void:
	body_sprite.modulate.v = V_MODULATE
