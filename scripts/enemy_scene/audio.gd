extends Node

@export var melee_comp: MeleeComp

@onready var hit_sound := $HitSound as AudioStreamPlayer


func _ready() -> void:
	melee_comp.executed.connect(func(_entity): if is_multiplayer_authority(): _play_hit_sound.rpc())


@rpc("any_peer", "call_local", "reliable")
func _play_hit_sound():
	hit_sound.play()
