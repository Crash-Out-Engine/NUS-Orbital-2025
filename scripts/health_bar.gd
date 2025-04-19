extends ProgressBar

@export var player: Player

func _ready() -> void:
	player.healthChanged.connect(update)
	
func update(new_ratio: float) -> void:
	value = 100 * new_ratio
