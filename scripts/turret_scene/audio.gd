extends Node

@export var turret_ranged: RangedBaseComp

@onready var gun_sound := $GunSound as AudioStreamPlayer


func _ready() -> void:
	turret_ranged.bullet_spawned.connect(func(_bullet): play_gun_sound())


func play_gun_sound() -> void:
	gun_sound.play()
