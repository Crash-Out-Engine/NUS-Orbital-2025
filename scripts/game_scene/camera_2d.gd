extends Camera2D

const PEEK_FACTOR = 0.15
<<<<<<< Updated upstream

@onready var player := get_parent() as Player

func _process(_delta: float) -> void:
	
	
	offset.x = PEEK_FACTOR * (get_global_mouse_position().x - player.global_position.x)
	offset.y = PEEK_FACTOR * (get_global_mouse_position().y - player.global_position.y)
=======

var MAX_RECT : Vector2

@onready var player := get_parent() as Player

var mouse_offset : Vector2

func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize) 
	resize()

var desired_offset: Vector2
var min_offset = -100
var max_offset = 100

func _process(_delta: float) -> void:
	desired_offset = (get_global_mouse_position() - position) * 0.5
	desired_offset.x = clamp(desired_offset.x, min_offset, max_offset)
	desired_offset.y = clamp(desired_offset.y, min_offset/2, max_offset/2)
	global_position = player.global_position + desired_offset
	
func resize() -> void:
	MAX_RECT = get_viewport().size * 0.2
>>>>>>> Stashed changes
	
