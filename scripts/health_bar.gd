extends TextureProgressBar

@export var player: Player
@onready var label: Label = $Label

func _ready() -> void:
	player.health_changed.connect(update)
	label.set_position(position + size/2 - label.size/2)
	label.text = str(player.get_health())
	
func update(new_ratio: float) -> void:
	value = 100 * new_ratio
	label.text = str(player.get_health())
