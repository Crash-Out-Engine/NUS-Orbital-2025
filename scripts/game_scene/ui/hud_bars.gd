extends Control

var active: bool = false
var info_text: Array[String]
var _player: Player
var _power_manager: PowerManager

@onready var health_bar := $VBoxContainer/HealthBar/TextureProgressBar as TextureProgressBar
@onready var health_label := (
		$VBoxContainer/HealthBar/TextureProgressBar/MarginContainer/Label as Label)
@onready var power_bar := $VBoxContainer/PowerBar/TextureProgressBar as TextureProgressBar
@onready var power_label := (
		$VBoxContainer/PowerBar/TextureProgressBar/MarginContainer/Label as Label)
@onready var power_slots := [
	$"VBoxContainer/PowerBar/1Bar",
	$"VBoxContainer/PowerBar/2Bar",
	$"VBoxContainer/PowerBar/4Bar",
	$"VBoxContainer/PowerBar/8Bar",
	$"VBoxContainer/PowerBar/16Bar"
] as Array[Control]
@onready var power_slots_on = [
	$"VBoxContainer/PowerBar/1Bar/On",
	$"VBoxContainer/PowerBar/2Bar/On",
	$"VBoxContainer/PowerBar/4Bar/On",
	$"VBoxContainer/PowerBar/8Bar/On",
	$"VBoxContainer/PowerBar/16Bar/On"
] as Array[TextureRect]
@onready var power_slots_off = [
	$"VBoxContainer/PowerBar/1Bar/Off",
	$"VBoxContainer/PowerBar/2Bar/Off",
	$"VBoxContainer/PowerBar/4Bar/Off",
	$"VBoxContainer/PowerBar/8Bar/Off",
	$"VBoxContainer/PowerBar/16Bar/Off"
] as Array[TextureRect]
@onready var scrap_label := $VBoxContainer/ScrapCounter/Icon/Label as Label
@onready var info_label := $VBoxContainer/RichTextLabel as RichTextLabel

func _process(delta: float) -> void:
	if active:
		update_power_bar(_power_manager.get_power() as int)
	if info_label.modulate.a > 0:
		info_label.modulate.a -= delta / 1.0
		if info_label.modulate.a <= 0:
			if info_text.size() > 0:
				show_info_label()


func setup(player: Player, power_manager: PowerManager):
	_player = player
	_power_manager = power_manager
	active = true

	update_health_bar()
	update_scraps_counter()
	_player.health_changed.connect(update_health_bar)
	_player.scraps_changed.connect(update_scraps_counter)
	_player.inventory.collected_mod.connect(show_mod_collected)
	_player.inventory.collected_blueprint.connect(show_blueprint_collected)


func update_health_bar() -> void:
	var ratio = _player.get_health() / _player.get_health_capacity()
	health_bar.value = 100.0 * ratio
	health_label.text = "%d/%d" % [_player.get_health(), _player.get_health_capacity()]


func update_power_bar(new_amount: int) -> void:
	power_bar.value = new_amount % 100
	power_label.text = str(new_amount)
	new_amount /= 100
	for i in 5:
		if (new_amount % 2 == 1):
			power_slots_on[i].visible = true
			power_slots_off[i].visible = false
		else:
			power_slots_on[i].visible = false
			power_slots_off[i].visible = true
		new_amount /= 2

	var is_on = false
	for i in range(4, -1, -1):
		if power_slots_on[i].visible:
			is_on = true
		power_slots[i].visible = is_on


func update_scraps_counter() -> void:
	scrap_label.text = str(_player.get_scraps())

func show_mod_collected(mod: Mod) -> void:
	info_text.append("[outline_size=8]Picked up %s%s[/outline_size]" % [mod.get_icon(), mod.name])
	if info_label.modulate.a <= 0:
		show_info_label()

func show_blueprint_collected(mod: Mod) -> void:
	info_text.append(
		"[outline_size=8]Gained blueprint for %s%s[/outline_size]" % [mod.get_icon(), mod.name])
	if info_label.modulate.a <= 0:
		show_info_label()

func show_info_label() -> void:
	info_label.text = info_text.pop_back()
	info_label.modulate.a = 1.0
