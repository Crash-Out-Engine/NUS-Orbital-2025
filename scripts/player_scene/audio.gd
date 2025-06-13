class_name PlayerAudio
extends Node

@export var player: Player
@export var player_ranged: RangedBaseComp
@export var player_melee: MeleeComp
@export var player_repair: MeleeComp

@onready var footsteps_sound := $FootstepsSound as AudioStreamPlayer
@onready var laser_sound := $LaserSound as AudioStreamPlayer
@onready var turret_placement_error_sound := $TurretPlacementErrorSound as AudioStreamPlayer
@onready var hit_sound := $HitSound as AudioStreamPlayer
@onready var repair_sound := $RepairSound as AudioStreamPlayer
@onready var melee_swing := $MeleeSwing as AudioStreamPlayer

func _ready() -> void:
	player.hand.action_changed.connect(_handle_hand_action_changed)
	player_ranged.bullet_spawned.connect(play_laser_sound)
	player.turret_placement_failed.connect(play_turret_placement_error_sound)
	player_melee.executed.connect(func(_entity): play_hit_sound())
	player_repair.executed.connect(func(_entity): play_repair_sound())


func _process(_delta: float) -> void:
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) != Vector2.ZERO:
		if !footsteps_sound.playing:
			footsteps_sound.play()
	else:
		footsteps_sound.stop()
		
func _handle_hand_action_changed(_from: Player.Hand.Action, to: Player.Hand.Action) -> void:
	const HA := Player.Hand.Action
	match to:
		HA.FIRING_WRENCH:
			play_melee_swing_sound()


func play_turret_placement_error_sound() -> void:
	turret_placement_error_sound.play()

func play_laser_sound(_bullet) -> void:
	laser_sound.play()

func play_hit_sound():
	hit_sound.play()

func play_repair_sound():
	repair_sound.play()

func play_melee_swing_sound():
	melee_swing.play()
