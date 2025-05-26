extends Node

@export var melee_comp: MeleeComp

@onready var hit_sound := $HitSound as AudioStreamPlayer


func _ready() -> void:
	melee_comp.executed.connect(func(_entity): play_hit_sound())
	

func play_hit_sound():
	hit_sound.play()
