extends Camera2D

const PEEK_FACTOR = 0.15

var max_rect: Vector2
var mouse_offset: Vector2
var desired_offset: Vector2
var min_offset: int = -100
var max_offset: int = 100

@export var player : Player


func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	resize()


func _process(_delta: float) -> void:
	desired_offset = (get_global_mouse_position() - position) * 0.5
	desired_offset.x = clamp(desired_offset.x, min_offset, max_offset)
	desired_offset.y = clamp(desired_offset.y, min_offset / 2, max_offset / 2)
	global_position = player.global_position + desired_offset


func resize() -> void:
	max_rect = get_viewport().size * 0.2
