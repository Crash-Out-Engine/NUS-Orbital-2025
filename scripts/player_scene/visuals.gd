class_name PlayerVisuals
extends Node2D

const V_MODULATE := 100000000.0
const BLEED_TIME := 2.0 / 30.0

@export var player: Player
@export var ranged_cooldown: RangedCooldownProp
@export var ranged: RangedBaseComp
@export var movement: MovementBaseComp

@onready var player_sprite := $PlayerSprite as AnimatedSprite2D
@onready var gun_sprite := $GunSprite as AnimatedSprite2D
@onready var gun_blast_sprite := $GunSprite/GunBlastSprite as AnimatedSprite2D


func _ready() -> void:
	player.health_changed.connect(play_bleed)
	player.hand.action_changed.connect(_handle_hand_action_changed)
	ranged.bullet_spawned.connect(func(_bullet): play_gun_fire())
	gun_sprite.play("gun_idle")


func _process(delta: float) -> void:
	# player_sprite processes
	var horizontal_dir = movement.movement_direction.x
	if horizontal_dir != 0:
		player_sprite.flip_h = horizontal_dir < 0
	if movement.movement_direction != Vector2.ZERO:
		player_sprite.play("running")
	else:
		player_sprite.play("idle")
	if (player_sprite.modulate.v > 1):
		player_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (player_sprite.modulate.v <= 1):
			player_sprite.modulate.v = 1

	# gun_sprite processes
	if !player.hand.locked:
		gun_sprite.rotation = player.hand.rotation
		gun_sprite.scale.y = 1 if absf(player.hand.rotation) < PI / 2.0 else -1


func _handle_hand_action_changed(_from: Player.Hand.Action, to: Player.Hand.Action) -> void:
	const HA := Player.Hand.Action
	match to:
		HA.FIRING_WRENCH:
			play_wrench_fire()
		HA.HOLDING_GUN:
			play_gun_idle()
		HA.PLANNING_WRENCH:
			play_wrench_idle()


func play_wrench_idle() -> void:
	gun_sprite.play("melee_idle")


func play_gun_idle() -> void:
	gun_sprite.play("gun_idle")


func play_gun_fire() -> void:
	gun_sprite.sprite_frames.set_animation_speed("gun_fire", 4.0 / ranged_cooldown.value)
	gun_sprite.play("gun_fire")
	gun_blast_sprite.sprite_frames.set_animation_speed("default", 4.0 / ranged_cooldown.value)
	gun_blast_sprite.play()


func play_wrench_fire() -> void:
	gun_sprite.play("melee_fire")


func play_bleed() -> void:
	player_sprite.modulate.v = V_MODULATE
