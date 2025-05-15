extends TextureProgressBar

@export var player: Player

@onready var _label := $Label as Label


func _ready() -> void:
	player.health_changed.connect(update)
	_label.set_position(position + size / 2 - _label.size / 2)
	_label.text = str(player.get_health())


func update(new_ratio: float) -> void:
	value = 100.0 * new_ratio
	_label.text = str(player.get_health())
