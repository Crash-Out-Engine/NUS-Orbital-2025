extends CanvasLayer

@onready var game = get_parent() as Game

func _ready() -> void:
	game.game_over.connect(func(_message): close_all_menus())

func _process(_delta: float) -> void:
	if !game.transitioning:
		if !$InventoryUI.is_open():
			$PauseMenu.try_esc()
		$DebugPanel.try_debug()
	$InventoryUI.try_open()

func close_all_menus() -> void:
	if $InventoryUI.is_open():
		$InventoryUI.force_close()
	set_process(false)
