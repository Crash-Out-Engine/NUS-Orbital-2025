class_name PlayerAudio
extends Node

@export var player: Player
@export var movement: MovementBaseComp
@export var melee_attack: MeleeComp
@export var melee_repair: MeleeComp

@onready var footsteps_sound := $FootstepsSound as AudioStreamPlayer
@onready var laser_sound := $LaserSound as AudioStreamPlayer
@onready var turret_placement_error_sound := $TurretPlacementErrorSound as AudioStreamPlayer
@onready var hit_sound := $HitSound as AudioStreamPlayer
@onready var repair_sound := $RepairSound as AudioStreamPlayer
@onready var melee_swing := $MeleeSwing as AudioStreamPlayer

func _ready() -> void:
	player.hand.action_changed.connect(
			func(from, to):
				if is_multiplayer_authority():
					_handle_hand_action_changed(from, to)
	)

	player.entity_spawned.connect(
			func(entity):
				if is_multiplayer_authority() and entity is Bullet:
					_play_laser_sound.rpc()
	)
	player.turret_placement_failed.connect(
			func():
				if is_multiplayer_authority():
					_play_turret_placement_error_sound.rpc()
	)
	melee_attack.executed.connect(
			func(entities: Array):
				if is_multiplayer_authority() and not entities.is_empty():
					_play_hit_sound.rpc()
	)
	melee_repair.executed.connect(
			func(entities: Array):
				if is_multiplayer_authority() and not entities.is_empty():
					_play_repair_sound.rpc()
	)


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if movement.movement_direction != Vector2.ZERO:
		if !footsteps_sound.playing:
			_play_footsteps_sound.rpc()
	else:
		_stop_footsteps_sound.rpc()


func _handle_hand_action_changed(_from: Player.Hand.Action, to: Player.Hand.Action) -> void:
	const HA = Player.Hand.Action
	match to:
		HA.FIRING_WRENCH:
			_play_melee_swing_sound.rpc()


@rpc("any_peer", "call_local", "reliable")
func _play_footsteps_sound() -> void:
	footsteps_sound.play()


@rpc("any_peer", "call_local", "reliable")
func _stop_footsteps_sound() -> void:
	footsteps_sound.stop()


@rpc("any_peer", "call_local", "reliable")
func _play_turret_placement_error_sound() -> void:
	turret_placement_error_sound.play()


@rpc("any_peer", "call_local", "reliable")
func _play_laser_sound() -> void:
	laser_sound.play()


@rpc("any_peer", "call_local", "reliable")
func _play_hit_sound():
	hit_sound.play()


@rpc("any_peer", "call_local", "reliable")
func _play_repair_sound():
	repair_sound.play()


@rpc("any_peer", "call_local", "reliable")
func _play_melee_swing_sound():
	melee_swing.play()
