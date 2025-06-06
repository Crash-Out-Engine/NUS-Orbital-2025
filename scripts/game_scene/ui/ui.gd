extends CanvasLayer

@onready var game = get_parent() as Game

func _process(_delta: float) -> void:
	if !game.transitioning:
		$PauseMenu.try_esc()
		$DebugPanel.try_debug()
