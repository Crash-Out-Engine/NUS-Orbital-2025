extends CenterContainer

@export var player: Player
@onready var label: Label = $Label
@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	player.health_changed.connect(update)
	label.text = str(player.get_health())
	
func update(new_ratio: float) -> void:
	health_bar.value = 100 * new_ratio
	label.text = str(player.get_health())
