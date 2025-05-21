extends Node

@onready var footsteps_sound := $FootstepsSound as AudioStreamPlayer
@onready var laser_sound := $LaserSound as AudioStreamPlayer
@onready var turret_placement_error_sound := $TurretPlacementErrorSound as AudioStreamPlayer
@onready var player := $".." as Player
@onready var player_ranged := $"../Ranged" as RangedBase
@onready var player_melee := $"../Melee" as Melee
@onready var hit_sound := $HitSound as AudioStreamPlayer



func _ready() -> void:
	player_ranged.bullet_spawned.connect(play_laser_sound)
	player.turret_placement_failed.connect(play_turret_placement_error_sound)
	player_melee.executed.connect(func(_entity): play_hit_sound())


func _process(_delta: float) -> void:
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) != Vector2.ZERO:
		if !footsteps_sound.playing:
			footsteps_sound.play()
	else:
		footsteps_sound.stop()


func play_turret_placement_error_sound() -> void:
	turret_placement_error_sound.play()


func play_laser_sound(_bullet) -> void:
	laser_sound.play()

func play_hit_sound():
	hit_sound.play()
