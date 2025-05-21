extends Camera2D

const PEEK_FACTOR = 0.15

@onready var player := get_parent() as Player

func _process(_delta: float) -> void:
	
	
	offset.x = PEEK_FACTOR * (get_global_mouse_position().x - player.global_position.x)
	offset.y = PEEK_FACTOR * (get_global_mouse_position().y - player.global_position.y)
	
