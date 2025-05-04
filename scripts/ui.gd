extends CanvasLayer

func _process(delta: float) -> void:
	$PauseMenu.try_esc()
