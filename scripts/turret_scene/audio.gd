extends Node

@export var ranged_comp: RangedBaseComp

@onready var gun_sound := $GunSound as AudioStreamPlayer


func _ready() -> void:
	ranged_comp.bullet_spawned.connect(func(_bullet): play_gun_sound())
	

func play_gun_sound() -> void:
	gun_sound.play()
