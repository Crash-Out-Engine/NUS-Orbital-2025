extends Control

@export var player : Player

@onready var scrap_counter_label = (
	$Margin/PanelContainer/HBox/LeftVBox/ScrapCounter/HBox/Label as Label)
@onready var mod_slot_size_label = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/HBox/ModSlotLabel as Label)
@onready var target_display = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/Sprite2DRect as Sprite2DRect)
@onready var disassemble_button = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/DisassembleButton as Button)
@onready var analysis = $Analysis as Container
@onready var analysis_label = $Analysis/PanelContainer/Label as Label

var inventory_comp : InventoryComp
var modslot_comp : ModSlotComp
var turret : Turret = null

func _ready() -> void:
	visible = false
	player.open_inventory.connect(opening_setup)

func try_open():
	if Input.is_action_just_pressed("inventory"):
		analysis.visible = false
		visible = !visible
		if !visible:
			player.close_inventory()

	if Input.is_action_just_pressed("esc"):
		if visible:
			if analysis.visible:
				analysis.visible = false
			else:
				visible = false
				player.close_inventory()


func is_open() -> bool:
	return visible

func opening_setup(inventory_input: InventoryComp, modslot_input: ModSlotComp):
	if inventory_comp != inventory_input:
		inventory_comp = inventory_input
		update_scrap_counter(inventory_comp.get_scraps())
		inventory_comp.scraps_changed.connect(
			func(_prev_value, new_value): update_scrap_counter(new_value))
	if modslot_comp != modslot_input:
		modslot_comp = modslot_input
		update_modslots_counter(modslot_comp._mods.size(), modslot_comp.capacity)
		modslot_comp.modslots_updated.connect(update_modslots_counter)

		if modslot_comp.get_parent().get_parent() is Turret:
			turret = modslot_comp.get_parent().get_parent()
		else:
			turret = null
		target_display.Frame = 0 if turret == null else 1
		disassemble_button.visible = !(turret == null)

func force_close():
	visible = false

func update_scrap_counter(scrap: int) -> void:
	scrap_counter_label.text = str(scrap)

func update_modslots_counter(mods: int, capacity: int) -> void:
	mod_slot_size_label.text = "%d/%d M.O.D.s equipped" % [mods, capacity]

func _on_more_info_button_pressed() -> void:
	analysis_label.text = "Analysis of %s" % (
		"Player" if modslot_comp.get_parent().get_parent() is Player else "Turret")
	#TODO: implement analysis texts
	analysis.visible = true


func _on_disassemble_button_pressed() -> void:
	turret.disassemble()
	analysis.visible = false
	visible = !visible
	player.close_inventory()
