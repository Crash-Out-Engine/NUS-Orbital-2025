extends Node

@onready var gun_sound := $GunSound as AudioStreamPlayer
@onready var turret_ranged := $"../Ranged" as RangedBase


func _ready() -> void:
	turret_ranged.bullet_spawned.connect(func(_bullet): play_gun_sound())
	

func play_gun_sound() -> void:
	gun_sound.play()
