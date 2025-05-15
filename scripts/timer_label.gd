class_name TimerLabel
extends Label

var elapsed_time: float = 0.0


func _ready() -> void:
	position = Vector2(get_viewport_rect().size.x / 2.0 - size.x / 2.0, size.y / 2.0)
	reset()


func _process(delta: float) -> void:
	elapsed_time += delta
	_set_text_seconds(elapsed_time)


func reset() -> void:
	elapsed_time = 0.0


func _set_text_seconds(time: float):
	var total_seconds := int(time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	text = "%02d:%02d" % [minutes, seconds]
