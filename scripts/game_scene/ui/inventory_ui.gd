extends Control

const ITEM_CONTAINER = preload("res://scenes/item_container.tscn")
const BLUEPRINT_CONTAINER = preload("res://scenes/blueprint_container.tscn")
const SCRAP_EMOJI = "res://resources/text_icons/scrap_icon.tres"

@export var player : Player
@export var unlocked_mods : Array[ModBase]

var crafting_scraps : int = 0
var crafting_output : ModBase = null
var checking_blueprints : bool = false
var selected_blueprint : int = 0
var scrap_diff : int
var turret : Turret = null
var inventory_comp : InventoryComp
var modslot_comp : ModSlotComp
var crafting_inputs : Array[ModBase] = []
var _crafting_components : Dictionary[PropertyPoint, int]

@onready var scrap_counter_label = (
	$Margin/PanelContainer/HBox/LeftVBox/ScrapCounter/HBox/Label as Label)
@onready var mod_slot_size_label = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/HBox/ModSlotLabel as Label)
@onready var target_display = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/Sprite2DRect as Sprite2DRect)
@onready var disassemble_button = (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/DisassembleButton as Button)
@onready var upgrade_button = (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/UpgradeButton as Button)
@onready var upgrade_button_label = (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/UpgradeButton/RichTextLabel as RichTextLabel)
@onready var inventory_mod_counter = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryModCounter as Label)
@onready var modcomp_list = (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/ScrollContainer/VBox as Container)
@onready var inventory_list = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryList/Margin/VBox as Container)
@onready var inventory_scroll = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryList as ScrollContainer)
@onready var blueprint_scroll = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/BlueprintList as ScrollContainer)
@onready var blueprint_list = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/BlueprintList/Margin/VBox
	as VBoxContainer)
@onready var blueprint_label = (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingOutput/VBox/BlueprintPanel/RichTextLabel
	as RichTextLabel)
@onready var crafting_inputs_list = (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingInput/ScrollContainer/VBox as Container)
@onready var crafting_instructions_label = (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingInput/CraftingInstructionsLabel as Label)
@onready var crafting_components_list = (
	$Margin/PanelContainer/HBox/RightVBox/CraftOptions/RichTextLabel as RichTextLabel)
@onready var crafting_output_label = (
	$Margin/PanelContainer/HBox/RightVBox/CraftButton/RichTextLabel as RichTextLabel)
@onready var craft_button = $Margin/PanelContainer/HBox/RightVBox/CraftButton as Button

@onready var analysis = $Analysis as Container
@onready var analysis_label = $Analysis/PanelContainer/Label as Label

func _ready() -> void:
	visible = false

func try_open():
	if Input.is_action_just_pressed("inventory"):
		if visible:
			if analysis.visible:
				analysis.visible = false
			else:
				close_inventory()
		else:
			visible = true
			opening_setup(player.get_inventory(), player.get_mod_slots())

	if Input.is_action_just_pressed("esc"):
		if visible:
			if analysis.visible:
				analysis.visible = false
			else:
				close_inventory()

func is_open() -> bool:
	return visible

func opening_setup(inventory_input: InventoryComp, modslot_input: ModSlotComp):
	if inventory_comp != inventory_input:
		inventory_comp = inventory_input
		update_inventory_list()
		inventory_comp.scraps_changed.connect(
			func(_prev_value, new_value): update_scrap_counter(new_value))

	if modslot_comp != modslot_input:
		if modslot_comp != null:
			modslot_comp.modslots_updated.disconnect(update_modslots_counter)
		modslot_comp = modslot_input
		update_modslotcomp_list()
		modslot_comp.modslots_updated.connect(update_modslots_counter)

		if modslot_comp.get_parent().get_parent() is Turret:
			turret = modslot_comp.get_parent().get_parent()
		else:
			turret = null
		target_display.frame = 0 if turret == null else 1
		disassemble_button.visible = !(turret == null)

	checking_blueprints = false
	selected_blueprint = 0
	setup_blueprint_list()
	crafting_inputs = []
	crafting_output = null
	update_crafting()
	player.open_inventory()

func force_close():
	close_inventory()

func close_inventory():
	analysis.visible = false
	visible = false
	if crafting_inputs.size() > 0:
		for i in crafting_inputs:
			inventory_comp._add_mod(i)
		crafting_inputs = []
	player.close_inventory()

func update_scrap_counter(scrap: int) -> void:
	scrap_counter_label.text = str(scrap)

func update_modslots_counter(mods: int, capacity: int) -> void:
	mod_slot_size_label.text = "%d/%d M.O.D.s equipped" % [mods, capacity]

func setup_blueprint_list():
	for item in blueprint_list.get_children():
		item.queue_free()
	var i = 0
	for mod in player.get_blueprints():
		var blueprint = BLUEPRINT_CONTAINER.instantiate() as BlueprintContainer
		blueprint.mod = mod
		blueprint.id = i
		i += 1
		blueprint_list.add_child(blueprint)
		blueprint.update()
		blueprint.pressed.connect(blueprint_selected)
	blueprint_list.get_children()[selected_blueprint].set_selected(true)
	blueprint_selected(selected_blueprint)

func blueprint_selected(selection: int):
	if selection == selected_blueprint:
		checking_blueprints = false
	else:
		blueprint_list.get_children()[selected_blueprint].set_selected(false)
		blueprint_list.get_children()[selection].set_selected(true)
		selected_blueprint = selection
	blueprint_label.text = blueprint_list.get_children()[selected_blueprint].get_mod_name()
	crafting_output = player.get_blueprints()[selected_blueprint]
	update_inventory_list()
	update_crafting_components()

func update_inventory_list():
	update_scrap_counter(inventory_comp.get_scraps())
	if checking_blueprints:
		inventory_scroll.visible = false
		blueprint_scroll.visible = true
		inventory_mod_counter.text = "%d M.O.D. options" % (player.get_blueprints().size() - 1)
	else:
		inventory_scroll.visible = true
		blueprint_scroll.visible = false

		var mod_array = inventory_comp.get_mods()
		for item in inventory_list.get_children():
			item.queue_free()
		var total = 0
		for mod in mod_array:
			if mod_array[mod] <= 0: continue #TODO: implement proper filter functions
			var item = ITEM_CONTAINER.instantiate()
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
		var item = ITEM_CONTAINER.instantiate()
		item.mod = mod
		item.state = ItemContainer.State.MODCOMP
		modcomp_list.add_child(item)
		item.update()
		item.create_dragged_item.connect(add_dragged_item)

	update_modslotcomp_upgrade()

func update_modslotcomp_upgrade():
	upgrade_button_label.text = "[color=#1c1c0d]Add slot(%d[img=32]%s[/img])[/color]" % [
		modslot_comp.get_upgrade_cost(),
		SCRAP_EMOJI]

	if modslot_comp.get_upgrade_cost() > player.get_scraps():
		upgrade_button.disabled = true
	else:
		upgrade_button.disabled = false

func update_crafting():
	for item in crafting_inputs_list.get_children():
		item.queue_free()
	if crafting_inputs.size() > 0:
		crafting_instructions_label.visible = false
		for mod in crafting_inputs:
			var item = ITEM_CONTAINER.instantiate()
			item.mod = mod
			item.state = ItemContainer.State.CRAFTING
			crafting_inputs_list.add_child(item)
			item.update()
			item.create_dragged_item.connect(add_dragged_item)
	else:
		crafting_instructions_label.visible = true
	update_crafting_components()

func update_crafting_components():
	_crafting_components.clear()
	crafting_scraps = 0
	for mod in crafting_inputs:
		crafting_scraps += mod.value
		for pp in mod.property_points:
			_crafting_components[pp] = _crafting_components.get_or_add(pp, 0) + mod.property_points[pp]
	crafting_scraps *= 4
	crafting_scraps /= 5
	crafting_components_list.text = ""
	scrap_diff = crafting_scraps
	if crafting_output != null:
		scrap_diff -= crafting_output.value
	if scrap_diff != 0:
		crafting_components_list.text += "%d[img=36]%s[/img]\n" % [scrap_diff, SCRAP_EMOJI]
	crafting_components_list.text += "[color=#46cd6d]Components:[/color]\n"
	if crafting_output == null:
		for pp in _crafting_components:
			crafting_components_list.text += "%s×%d\n" % [pp.get_icon(36), _crafting_components[pp]]
		if crafting_scraps == 0:
			crafting_output_label.text = ""
			craft_button.disabled = true
		else:
			crafting_output_label.text = "Recycle for %d[img=32]%s[/img]" % [crafting_scraps, SCRAP_EMOJI]
			craft_button.disabled = false
	else:
		for pp in _crafting_components:
			if crafting_output.property_points.get(pp, 0) > 0:
				crafting_components_list.text += "%s[color=%s]×%d/%d[/color]\n" % [
					pp.get_icon(36),
					"#ed1C24" if crafting_output.property_points[pp] > _crafting_components[pp]
					else "#46cd6d",
					_crafting_components[pp],
					crafting_output.property_points[pp]]
			else:
				crafting_components_list.text += "%s×%d\n" % [pp.get_icon(36), _crafting_components[pp]]
		var sufficient_components = true
		for pp in crafting_output.property_points:
			if _crafting_components.get(pp) == null:
				sufficient_components = false
				crafting_components_list.text += "%s[color=#ed1c24]×0/%d[/color]\n" % [
					pp.get_icon(36),
					crafting_output.property_points[pp]]
		if !sufficient_components:
			crafting_output_label.text = "Insufficient components!"
			craft_button.disabled = true
		else:
			if crafting_scraps + player.get_scraps() >= crafting_output.value:
				if scrap_diff > 0:
					crafting_output_label.text = "Craft %s%s and gain %d[img=36]%s[/img]" % [
						crafting_output.get_icon(36),
						crafting_output.name,
						scrap_diff,
						SCRAP_EMOJI
					]
				elif scrap_diff == 0:
					crafting_output_label.text = "Craft %s%s" % [
						crafting_output.get_icon(36),
						crafting_output.name
					]
				else:
					crafting_output_label.text = "Craft %s%s for %d[img=36]%s[/img]" % [
						crafting_output.get_icon(36),
						crafting_output.name,
						scrap_diff,
						SCRAP_EMOJI
					]
				craft_button.disabled = false
			else:
				crafting_output_label.text = "%d more [img=36]%s[/img] required!" % [
					crafting_output.value - (crafting_scraps + player.get_scraps()),
					SCRAP_EMOJI
				]

func set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int):
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)

func _on_more_info_button_pressed() -> void:
	analysis_label.text = "Analysis of %s" % (
		"Player" if modslot_comp.get_parent().get_parent() is Player else "Turret")
	#TODO: implement analysis texts
	analysis.visible = true

func _on_disassemble_button_pressed() -> void:
	turret.disassemble()
	close_inventory()

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
			crafting_inputs.erase(item.mod)
			update_crafting()

func insert_item(mod: ModBase, destination: ItemContainer.State):
	match(destination):
		ItemContainer.State.MODCOMP:
			if modslot_comp._add_mod(mod):
				update_modslotcomp_list()
			else:
				inventory_comp._add_mod(mod)
				update_inventory_list()

		ItemContainer.State.INVENTORY:
			inventory_comp._add_mod(mod)
			update_inventory_list()

		ItemContainer.State.CRAFTING:
			crafting_inputs.append(mod)
			update_crafting()


func _on_upgrade_button_pressed() -> void:
	player.use_scraps(modslot_comp.get_upgrade_cost())
	modslot_comp.change_capcity(1)
	update_modslotcomp_upgrade()


func _on_blueprints_button_pressed() -> void:
	checking_blueprints = !checking_blueprints
	update_inventory_list()


func _on_craft_button_pressed() -> void:
	if scrap_diff < 0:
		player.use_scraps(-scrap_diff)
	else:
		player.inventory.register_item(Item.ScrapItem.new(scrap_diff))
	if crafting_output != null:
		crafting_inputs = [crafting_output]
	else:
		crafting_inputs = []
	checking_blueprints = false
	update_crafting()
	blueprint_selected(0)


func _on_exit_button_pressed() -> void:
	analysis.visible = false
