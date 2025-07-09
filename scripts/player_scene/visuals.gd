class_name PlayerVisuals
extends Node2D

signal melee_finished()

const V_MODULATE := 100000000.0
const BLEED_TIME := 2.0 / 30.0

@export var player: Player
@export var melee_cooldown: MeleeCooldownProp
@export var ranged_cooldown: RangedCooldownProp
@export var movement: MovementBaseComp

@onready var player_sprite := $PlayerSprite as AnimatedSprite2D
@onready var gun_sprite := $GunSprite as AnimatedSprite2D
@onready var gun_blast_sprite := $GunSprite/GunBlastSprite as AnimatedSprite2D
@onready var gun_reload_bar := $GunSprite/ReloadBarSprite as Sprite2D

func _ready() -> void:
	player.state_changed.connect(
			func(from, to):
				if is_multiplayer_authority():
					_handle_state_changed(from, to)
	)
	player.hand.action_changed.connect(
			func(from, to):
				if is_multiplayer_authority():
					_handle_hand_action_changed(from, to)
	)

	player.entity_spawned.connect(
			func(entity):
				if is_multiplayer_authority() and entity is Bullet:
					_play_gun_fire.rpc()
	)
	player.health_changed.connect(
			func():
				if is_multiplayer_authority():
					_play_bleed.rpc()
	)


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	# player_sprite processes
	if (player_sprite.modulate.v > 1):
		player_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (player_sprite.modulate.v <= 1):
			player_sprite.modulate.v = 1

	if not player.state in [Player.State.PLAYING, Player.State.INVENTORY]:
		return

	if movement.movement_direction.x != 0:
		player_sprite.flip_h = movement.movement_direction.x < 0
	if movement.movement_direction != Vector2.ZERO:
		_play_running.rpc()
	else:
		_play_idle.rpc()

	# gun_sprite processes
	gun_sprite.rotation = player.hand.rotation
	gun_sprite.scale.y = 1 if absf(player.hand.rotation) < PI / 2.0 else -1
	gun_reload_bar.frame = floor(
		4 * (1 - ranged_cooldown._timer.time_left / ranged_cooldown.value))


func _handle_state_changed(_from: Player.State, to: Player.State) -> void:
	const PS = Player.State
	match to:
		PS.DEAD:
			_play_death.rpc()
		PS.LOST:
			_play_lost.rpc()


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
func _play_bleed():
	player_sprite.modulate.v = V_MODULATE


@rpc("any_peer", "call_local", "reliable")
func _play_death():
	player_sprite.modulate.v = 1
	player_sprite.play("death")
	gun_sprite.visible = false


@rpc("any_peer", "call_local", "reliable")
func _play_lost():
	player_sprite.play("lost")
	gun_sprite.visible = false


@rpc("any_peer", "call_local", "reliable")
func _play_wrench_idle() -> void:
	gun_reload_bar.visible = false
	gun_sprite.play("melee_idle")


@rpc("any_peer", "call_local", "reliable")
func _play_wrench_fire():
	gun_reload_bar.visible = false
	gun_sprite.play("melee_fire", 0.5 / melee_cooldown.value)


@rpc("any_peer", "call_local", "reliable")
func _play_gun_idle() -> void:
	gun_sprite.play("gun")
	gun_reload_bar.visible = true


@rpc("any_peer", "call_local", "reliable")
func _play_gun_fire() -> void:
	gun_sprite.play("gun")
	gun_reload_bar.visible = true
	gun_blast_sprite.play()


@rpc("any_peer", "call_local", "reliable")
func _play_running() -> void:
	player_sprite.play("running")


@rpc("any_peer", "call_local", "reliable")
func _play_idle() -> void:
	player_sprite.play("idle")


func _on_gun_sprite_animation_finished() -> void:
	if gun_sprite.animation == "melee_fire":
		melee_finished.emit()
