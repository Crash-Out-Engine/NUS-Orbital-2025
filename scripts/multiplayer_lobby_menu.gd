extends Control


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			visible = false


func _on_texture_button_pressed() -> void:
	visible = false
