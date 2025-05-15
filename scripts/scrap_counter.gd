extends HBoxContainer

@export var player: Player

@onready var label: Label = $Label


func _ready() -> void:
	player.scrap_changed.connect(update)
	update()


func update() -> void:
	label.text = "%d/%d" % [player.scrap, player.turret_cost]
