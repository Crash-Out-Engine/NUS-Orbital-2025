extends Camera2D

const PEEK_FACTOR = 0.2

var MAX_RECT : Vector2

@onready var player := get_parent() as Player

var mouse_offset : Vector2

func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize) 
	resize()

func _process(_delta: float) -> void:
	mouse_offset = Vector2(get_global_mouse_position().x - player.global_position.x, get_global_mouse_position().y - player.global_position.y)
	if abs(mouse_offset.x) > MAX_RECT.x:
		mouse_offset.x = MAX_RECT.x * (1 if get_global_mouse_position().x > player.global_position.x else -1)
	if abs(mouse_offset.y) > MAX_RECT.y:
		mouse_offset.y = MAX_RECT.y * (1 if get_global_mouse_position().y > player.global_position.y else -1)
	offset = mouse_offset * PEEK_FACTOR
	
func resize() -> void:
	MAX_RECT = get_viewport().size * 0.25
	
