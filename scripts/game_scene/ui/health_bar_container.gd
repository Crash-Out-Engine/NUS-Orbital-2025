extends CenterContainer

@export var player: Player

@onready var _label := $Label as Label
@onready var _health_bar := $HealthBar as TextureProgressBar


func _ready() -> void:
	player.health_changed.connect(update)
	_label.set_position(position + size / 2 - _label.size / 2)
	_label.text = str(player.get_health() as int)


func update(new_ratio: float) -> void:
	_health_bar.value = 100.0 * new_ratio
	_label.text = str(player.get_health() as int)
