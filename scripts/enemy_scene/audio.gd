extends Node

@export var melee_comp: MeleeComp
@export var ranged: RangedBaseComp

@onready var gun_sound := $GunSound as AudioStreamPlayer
@onready var hit_sound := $HitSound as AudioStreamPlayer


func _ready() -> void:
	melee_comp.executed.connect(
			func(_entities):
				if is_multiplayer_authority():
					_play_hit_sound.rpc()
	)
	ranged.bullet_spawned.connect(
			func(_bullet):
				if is_multiplayer_authority():
					play_gun_sound.rpc()
	)


@rpc("any_peer", "call_local", "reliable")
func _play_hit_sound():
	hit_sound.play()

@rpc("any_peer", "call_local", "reliable")
func play_gun_sound() -> void:
	gun_sound.play()
