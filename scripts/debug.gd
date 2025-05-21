extends Control

@onready var label = $Label
@export var player : Player

func try_debug():
	if(Input.is_action_just_pressed("debug")):
		visible = !visible

func _process(_delta: float) -> void:
	label.text = ""
	label.text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	label.text += "Player position: (Global)" + str(player.global_position) + " (Local): " + str(player.position) + "\n"
	label.text += "Mouse position: (Global): " + str(get_global_mouse_position()) + " (Local): " + str(get_local_mouse_position()) + "\n"
