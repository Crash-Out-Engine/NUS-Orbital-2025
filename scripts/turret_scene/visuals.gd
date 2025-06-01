extends Node2D

const BLEED_TIME = 0.125
const V_MODULATE = 100000000
const GREEN = Color("#36e312")

@export var turret: Turret
@export var turret_ranged: RangedBaseComp
@export var turret_health: HealthProp
@export var turret_health_capacity: HealthCapacityProp

@onready var base_sprite := $BaseSprite as Sprite2D
@onready var body_sprite := $BodySprite as AnimatedSprite2D
@onready var build_progress := $BuildProgressBar as TextureProgressBar


func _ready() -> void:
	turret_ranged.bullet_spawned.connect(func(_bullet): play_fire_anim())
	turret_health.changed.connect(func(from, to): if from > to: bleed())
	turret_health.changed.connect(func(_from, to): update_health_bar(to))
	turret.state_changed.connect(handle_state_changed)
	turret.build_progressed.connect(handle_build_progress)
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
			build_progress.visible = false
			body_sprite.visible = true
			set_visual_modulate(Color(0, 1, 1, 0.5))

		[_, Turret.State.PLANNED]:
			build_progress.modulate = Color(1, 1, 1, 1)
			build_progress.value = 0
			build_progress.visible = true
			body_sprite.visible = false
			set_visual_modulate(Color(1, 1, 1, 1))

		[_, Turret.State.OPERATIONAL]:
			build_progress.visible = false
			build_progress.modulate = GREEN
			body_sprite.visible = true
			set_visual_modulate(Color(1, 1, 1, 1))

func handle_build_progress(progress: float) -> void:
	build_progress.value = progress * 100

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

func update_health_bar(value: float) -> void:
	build_progress.value = value / turret_health_capacity.value * 100
	build_progress.visible = build_progress.value < 100
