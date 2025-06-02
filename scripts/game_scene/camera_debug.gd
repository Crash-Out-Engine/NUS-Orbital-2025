extends DebugVisualsBase


func _draw() -> void:
	debug_rect()


func debug_rect() -> void:
	var max_rect = get_parent()._max_offset_rect / get_parent().scale
	draw_rect(Rect2(-max_rect / 2, max_rect), Color.GREEN_YELLOW, false, 0.5, true)
