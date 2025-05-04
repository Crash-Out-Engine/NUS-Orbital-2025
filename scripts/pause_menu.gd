extends Control

func _ready() -> void:
	visible = get_tree().paused

func resume():
	visible = false
	get_tree().paused = false
	
func pause():
	get_tree().paused = true
	visible = true

func restart():
	get_tree().reload_current_scene()
	
func try_esc():
	if Input.is_action_just_pressed("esc") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	restart()
