extends CanvasLayer

func _process(_delta: float) -> void:
	$PauseMenu.try_esc()
