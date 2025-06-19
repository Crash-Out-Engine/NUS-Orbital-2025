class_name PlayerAudio
extends Node

@export var player: Player

@export_group("Components")
@export var ranged: RangedBaseComp
@export var melee: MeleeComp
@export var repair: MeleeComp
@export var movement: MovementBaseComp

@onready var footsteps_sound := $FootstepsSound as AudioStreamPlayer
@onready var laser_sound := $LaserSound as AudioStreamPlayer
@onready var turret_placement_error_sound := $TurretPlacementErrorSound as AudioStreamPlayer
@onready var hit_sound := $HitSound as AudioStreamPlayer
@onready var repair_sound := $RepairSound as AudioStreamPlayer
@onready var melee_swing := $MeleeSwing as AudioStreamPlayer

func _ready() -> void:
	# As the multiplayer authority has not been set at the point of _ready being
	# called, all signal connections have to check for is_multiplayer_authority().
	player.hand.action_changed.connect(
			func(from, to): if is_multiplayer_authority(): _handle_hand_action_changed(from, to))
	ranged.bullet_spawned.connect(func(): if is_multiplayer_authority(): _play_laser_sound.rpc())
	player.turret_placement_failed.connect(
			func(): if is_multiplayer_authority(): _play_turret_placement_error_sound.rpc())
	melee.executed.connect(func(_entity): if is_multiplayer_authority(): _play_hit_sound.rpc())
	repair.executed.connect(func(_entity): if is_multiplayer_authority(): _play_repair_sound.rpc())


func _process(_delta: float) -> void:
	if movement.movement_direction != Vector2.ZERO:
		if !footsteps_sound.playing:
			_play_footsteps_sound.rpc()
	else:
		_stop_footsteps_sound.rpc()

func _handle_hand_action_changed(_from: Player.Hand.Action, to: Player.Hand.Action) -> void:
	const HA := Player.Hand.Action
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
func _play_laser_sound(_bullet) -> void:
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
