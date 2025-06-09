extends Control

const _ITEM_CONTAINER = preload("res://scenes/item_container.tscn")

@export var player : Player

@onready var scrap_counter_label = (
	$Margin/PanelContainer/HBox/LeftVBox/ScrapCounter/HBox/Label as Label)
@onready var mod_slot_size_label = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/HBox/ModSlotLabel as Label)
@onready var target_display = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/Sprite2DRect as Sprite2DRect)
@onready var disassemble_button = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/DisassembleButton as Button)
@onready var inventory_mod_counter = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryModCounter as Label)
@onready var modcomp_list = (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/ScrollContainer/VBox as Container)
@onready var inventory_list = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryList/Margin/VBox as Container)
@onready var crafting_input_container = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftingSlotGraphic/Control/CraftInput 
	as Container)
@onready var crafting_instructions_label = (
	$Margin/PanelContainer/HBox/RightVBox/CraftOptions/Label as Label)
@onready var analysis = $Analysis as Container
@onready var analysis_label = $Analysis/PanelContainer/Label as Label

var inventory_comp : InventoryComp
var modslot_comp : ModSlotComp
var crafting_input : ModBase = null
var turret : Turret = null

func _ready() -> void:
	visible = false
	player.inform_inventory.connect(opening_setup)

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
		update_inventory_list()
		inventory_comp.scraps_changed.connect(
			func(_prev_value, new_value): update_scrap_counter(new_value))

	if modslot_comp != modslot_input:
		modslot_comp = modslot_input
		update_modslotcomp_list()
		modslot_comp.modslots_updated.connect(update_modslots_counter)

		if modslot_comp.get_parent().get_parent() is Turret:
			turret = modslot_comp.get_parent().get_parent()
		else:
			turret = null
		target_display.Frame = 0 if turret == null else 1
		disassemble_button.visible = !(turret == null)

	player.open_inventory()

func force_close():
	visible = false

func update_scrap_counter(scrap: int) -> void:
	scrap_counter_label.text = str(scrap)

func update_modslots_counter(mods: int, capacity: int) -> void:
	mod_slot_size_label.text = "%d/%d M.O.D.s equipped" % [mods, capacity]

func update_inventory_list():
	update_scrap_counter(inventory_comp.get_scraps())
	var mod_array = inventory_comp.get_mods()
	for item in inventory_list.get_children():
		item.queue_free()
	var total = 0
	for mod in mod_array:
		if mod_array[mod] <= 0: continue #TODO: implement proper filter functions
		var item = _ITEM_CONTAINER.instantiate()
		item.mod = mod
		item.state = ItemContainer.State.INVENTORY
		item.count = mod_array[mod]
		total += item.count
		inventory_list.add_child(item)
		item.update()
		item.create_dragged_item.connect(add_dragged_item)
	inventory_mod_counter.text = "%d unique M.O.D.s, %d in total" % [mod_array.size(), total]

func update_modslotcomp_list():
	var mod_array = modslot_comp.get_mods()
	update_modslots_counter(mod_array.size(), modslot_comp.capacity)

	for item in modcomp_list.get_children():
		item.queue_free()
	for mod in mod_array:
		var item = _ITEM_CONTAINER.instantiate()
		item.mod = mod
		item.state = ItemContainer.State.MODCOMP
		modcomp_list.add_child(item)
		item.update()
		item.create_dragged_item.connect(add_dragged_item)

func update_crafting_slot():
	for item in crafting_input_container.get_children():
		item.queue_free()
	if crafting_input != null:
		var item = _ITEM_CONTAINER.instantiate()
		item.mod = crafting_input
		item.state = ItemContainer.State.CRAFTING
		crafting_input_container.add_child(item)
		item.update()
		item.create_dragged_item.connect(add_dragged_item)
	crafting_instructions_label.visible = (crafting_input == null)

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

func add_dragged_item(item: DraggedItem, state: ItemContainer.State):
	add_child(item)
	item.dropped.connect(insert_item)
	match(state):
		ItemContainer.State.MODCOMP:
			modslot_comp._remove_mod(item.mod)
			update_modslotcomp_list()
		ItemContainer.State.INVENTORY:
			inventory_comp._remove_mod(item.mod)
			update_inventory_list()
		ItemContainer.State.CRAFTING:
			crafting_input = null
			update_crafting_slot()

func insert_item(mod: ModBase, destination: ItemContainer.State):
	match(destination):
		ItemContainer.State.MODCOMP:
			modslot_comp._add_mod(mod)
			update_modslotcomp_list()

		ItemContainer.State.INVENTORY:
			inventory_comp._add_mod(mod)
			update_inventory_list()

		ItemContainer.State.CRAFTING:
			crafting_input = mod
			update_crafting_slot()
