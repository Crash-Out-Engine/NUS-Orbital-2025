class_name PlayerVisuals
extends Node2D
## Controls all player visuals.
##
## Asides from the rpc methods ([code]_play_*[/code]), all code should be run only at the authority.

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
	# As the multiplayer authority has not been set at the point of _ready being
	# called, all signal connections have to check for is_multiplayer_authority().
	player.health_changed.connect(func(): if is_multiplayer_authority(): _play_bleed.rpc())
	player.hand.action_changed.connect(
			func(from, to): if is_multiplayer_authority(): _handle_hand_action_changed(from, to))
	ranged.bullet_spawned.connect(func(_bullet): if is_multiplayer_authority(): _play_gun_fire.rpc())


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	# player_sprite processes
	var horizontal_dir = movement.movement_direction.x
	if horizontal_dir != 0:
		player_sprite.flip_h = horizontal_dir < 0
	if movement.movement_direction != Vector2.ZERO:
		_play_running.rpc()
	else:
		_play_idle.rpc()
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
				_play_wrench_fire.rpc()
			HA.HOLDING_GUN:
				_play_gun_idle.rpc()
			HA.PLANNING_WRENCH:
				_play_wrench_idle.rpc()


@rpc("any_peer", "call_local", "reliable")
func _play_wrench_idle() -> void:
	gun_sprite.play("melee_idle")


@rpc("any_peer", "call_local", "reliable")
func _play_gun_idle() -> void:
	gun_sprite.play("gun_idle")


@rpc("any_peer", "call_local", "reliable")
func _play_gun_fire() -> void:
	gun_sprite.sprite_frames.set_animation_speed("gun_fire", 4.0 / ranged_cooldown.value)
	gun_sprite.play("gun_fire")
	gun_blast_sprite.sprite_frames.set_animation_speed("default", 4.0 / ranged_cooldown.value)
	gun_blast_sprite.play()


@rpc("any_peer", "call_local", "reliable")
func _play_wrench_fire() -> void:
	gun_sprite.play("melee_fire")


@rpc("any_peer", "call_local", "reliable")
func _play_bleed() -> void:
	player_sprite.modulate.v = V_MODULATE


@rpc("any_peer", "call_local", "reliable")
func _play_running() -> void:
	player_sprite.play("running")


@rpc("any_peer", "call_local", "reliable")
func _play_idle() -> void:
	player_sprite.play("idle")
