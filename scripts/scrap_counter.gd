extends HBoxContainer

@export var player: Player
@onready var label: Label = $Label

func _ready() -> void:
	player.scrap_changed.connect(update)
	update()

func update() -> void:
	label.text = str(player.scrap) + "/" + str(player.turret_cost)
