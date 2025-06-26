extends Node2D

const BLEED_TIME = 0.125
const V_MODULATE = 100000000
const RED = Color("#e31212")
const YELLOW = Color("#e3c712")
const GREEN = Color("#36e312")

@export var turret: Turret

@export_group("Properties")
@export var health: HealthProp
@export var health_capacity: HealthCapacityProp
@export var ranged_cooldown: RangedCooldownProp

@onready var base_sprite := $BaseSprite as Sprite2D
@onready var body_sprite := $BodySprite as AnimatedSprite2D
@onready var highlight := $Highlight as Sprite2D
@onready var build_progress := $BuildProgressBar as TextureProgressBar


func _ready() -> void:
	turret.entity_spawned.connect(
			func(entity):
				if is_multiplayer_authority() and entity is Bullet:
					_play_fire_anim.rpc()
	)
	health.changed.connect(func(from, to):
			if is_multiplayer_authority() and from > to:
				_bleed()
	)
	health.changed.connect(
			func(_from, to):
				if is_multiplayer_authority():
					_update_health_bar(to)
	)
	turret.state_changed.connect(
			func(from, to):
				if is_multiplayer_authority():
					_handle_state_changed(from, to)
	)
	turret.build_progressed.connect(
			func(progress):
				if is_multiplayer_authority():
					_update_build_progress(progress)
	)
	base_sprite.rotation = randf_range(0.0, 360.0)


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	# Animation & transform
	if !body_sprite.is_playing():
		_play_idle_anim.rpc()
	highlight.rotation = body_sprite.rotation
	highlight.visible = turret.highlighted

	# Modulate effect
	if (body_sprite.modulate.v > 1.0):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1.0):
			body_sprite.modulate.v = 1.0


func _handle_state_changed(from: Turret.State, to: Turret.State) -> void:
	match [from, to]:
		[_, Turret.State.PLACING_INVALID]:
			build_progress.visible = false
			body_sprite.visible = true
			_set_visual_modulate(Color(1, 0, 0, 0.5))

		[_, Turret.State.PLACING_VALID]:
			build_progress.visible = false
			body_sprite.visible = true
			_set_visual_modulate(Color(0, 1, 1, 0.5))

		[_, Turret.State.PLANNED]:
			build_progress.modulate = Color(1, 1, 1, 1)
			build_progress.value = 0
			build_progress.fill_mode = 4
			build_progress.visible = true
			body_sprite.visible = false
			_set_visual_modulate(Color(1, 1, 1, 1))

		[_, Turret.State.OPERATIONAL]:
			build_progress.visible = false
			build_progress.fill_mode = 5
			body_sprite.visible = true
			_set_visual_modulate(Color(1, 1, 1, 1))


func _set_visual_modulate(color: Color) -> void:
	base_sprite.self_modulate = color
	body_sprite.self_modulate = color


func _bleed() -> void:
	body_sprite.modulate.v = V_MODULATE


func _update_build_progress(progress: float) -> void:
	build_progress.value = progress * 100


func _update_health_bar(value: float) -> void:
	var v = (value / health_capacity.value) * 100
	build_progress.value = v
	build_progress.visible = v < 100
	build_progress.modulate = GREEN if v >= 50 else YELLOW if v >= 25 else RED


@rpc("any_peer", "call_local", "reliable")
func _play_idle_anim() -> void:
	body_sprite.play("idle")


@rpc("any_peer", "call_local", "reliable")
func _play_fire_anim() -> void:
	body_sprite.sprite_frames.set_animation_speed("fire", 4.0 / ranged_cooldown.value)
	body_sprite.play("fire")

