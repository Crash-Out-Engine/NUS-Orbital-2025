extends Node

@onready var enemy_melee := $"../Melee" as Melee
@onready var hit_sound := $HitSound as AudioStreamPlayer


func _ready() -> void:
	enemy_melee.executed.connect(func(_entity): play_hit_sound())
	

func play_hit_sound():
	hit_sound.play()
