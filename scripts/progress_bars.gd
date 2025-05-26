extends Control

@export var player: Player
@export var game: Node2D

@onready var health_bar := $HealthBar/TextureProgressBar as TextureProgressBar
@onready var health_label := $HealthBar/TextureProgressBar/Label as Label
@onready var power_bar := $PowerBar/TextureProgressBar
@onready var power_label := $PowerBar/TextureProgressBar/Label
@onready var power_slots = [$"PowerBar/1Bar", $"PowerBar/2Bar", $"PowerBar/4Bar", $"PowerBar/8Bar", $"PowerBar/16Bar"]
@onready var power_slot_on = [$"PowerBar/1Bar/On", $"PowerBar/2Bar/On", $"PowerBar/4Bar/On", $"PowerBar/8Bar/On", $"PowerBar/16Bar/On"]
@onready var power_slot_off = [$"PowerBar/1Bar/Off", $"PowerBar/2Bar/Off", $"PowerBar/4Bar/Off", $"PowerBar/8Bar/Off", $"PowerBar/16Bar/Off"]
@onready var scrap_label := $ScrapCounter/TextureRect/Label

func _ready() -> void:
	player.health_changed.connect(update_healthbar)
	player.scrap_changed.connect(update_scrapcounter)


func _process(_delta: float) -> void:
	update_powerbar(game.power as int)

func update_healthbar(new_ratio: float) -> void:
	health_bar.value = 100.0 * new_ratio
	health_label.text = " Health:" + str(player.get_health()) + "/" + str(player.get_health_capacity())

func update_powerbar(new_amount: int) -> void:
	var amount = new_amount
	power_bar.value = amount%100
	power_label.text = " Power: " + str(amount%100)
	amount /= 100
	for i in 5:
		if(amount%2 == 1):
			power_slot_on[i].visible = true
			power_slot_off[i].visible = false
		else:
			power_slot_on[i].visible = false
			power_slot_off[i].visible = true
		amount /= 2
	var b = false
	for i in range(4, -1, -1):
		if power_slot_on[i].visible:
			b = true
		power_slots[i].visible = b

func update_scrapcounter(new_amount: int) -> void:
	scrap_label.text = str(new_amount)
