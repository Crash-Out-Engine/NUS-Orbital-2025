class_name InventoryUI
extends Control

signal closed()

const ITEM_CONTAINER = preload("res://scenes/item_container.tscn")
const BLUEPRINT_CONTAINER = preload("res://scenes/blueprint_container.tscn")
const SCRAP_EMOJI = "res://resources/text_icons/scrap_icon.tres"
const INFO_ICON = "res://resources/text_icons/info.tres"

@export var unlocked_mods: Array[Mod]

var crafting_scraps: int = 0
var crafting_output: Mod = null
var checking_blueprints: bool = false
var selected_blueprint: Mod = null
var scrap_diff: int
var analysis_shown: bool = false
var dragged_item: Mod = null
var inventory_comp: InventoryComp
var modslot_comp: ModSlotComp
var crafting_inputs: Array[Mod] = []
var _crafting_components: Dictionary[PropertyPoint, int]

@onready var scrap_counter_label := (
	$Margin/PanelContainer/HBox/LeftVBox/ScrapCounter/HBox/Label as Label)
@onready var mod_slot_size_label := (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/HBox/ModSlotLabel as Label)
@onready var target_display_anim := %TargetDisplayAnimation as AnimatedSprite2D
@onready var target_display_label := %TargetDisplayLabel as RichTextLabel
@onready var disassemble_button := (
	$Margin/PanelContainer/HBox/LeftVBox/TargetDisplay/VBox/DisassembleButton as Button)
@onready var upgrade_button := (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/UpgradeButton as Button)
@onready var upgrade_button_label := (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/UpgradeButton/RichTextLabel as RichTextLabel)
@onready var inventory_mod_counter := (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryModCounter as Label)
@onready var modcomp_list := (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/ScrollContainer/VBox as Container)
@onready var inventory_list := (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryList/Margin/VBox as Container)
@onready var inventory_scroll := (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryList as ScrollContainer)
@onready var blueprint_scroll := (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/BlueprintList as ScrollContainer)
@onready var blueprint_list := (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/BlueprintList/Margin/VBox
	as VBoxContainer)
@onready var blueprint_label := (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingOutput/VBox/BlueprintPanel/RichTextLabel
	as RichTextLabel)
@onready var blueprint_description_panel := %BlueprintDescriptionPanel as PanelContainer
@onready var blueprint_button_description := %RichTextLabel as RichTextLabel
@onready var crafting_inputs_list := (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingInput/ScrollContainer/VBox as Container)
@onready var crafting_instructions_label := (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingInput/CraftingInstructionsLabel as Label)
@onready var crafting_components_list := (
	$Margin/PanelContainer/HBox/RightVBox/CraftOptions/RichTextLabel as RichTextLabel)
@onready var crafting_output_label := (
	$Margin/PanelContainer/HBox/RightVBox/CraftButton/RichTextLabel as RichTextLabel)
@onready var craft_button = $Margin/PanelContainer/HBox/RightVBox/CraftButton as Button
@onready var search_bar := (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/SearchBar as LineEdit)
@onready var can_affect_filter := %CanAffectFilter as DropdownCheckboxesContainer
@onready var component_filter := %ComponentFilter as DropdownCheckboxesContainer
@onready var particles := (
	$Margin/PanelContainer/HBox/RightVBox/HBox/CraftingInput/CPUParticles2D as CPUParticles2D)
@onready var audio := $Audio as InventoryAudio


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("LMB"):
		if search_bar.has_focus():
			if !search_bar.get_global_rect().has_point(get_global_mouse_position()):
				search_bar.release_focus()


func setup(game: Game, player: Player) -> void:
	inventory_comp = player.get_inventory()
	game.game_over.connect(func(_message): _close_inventory())


## Opens the inventory UI.
## [br]
## Returns an [signal InventoryUI.closed] signal that emits when the inventory
## UI is closed.
func open() -> Signal:
	visible = true
	opening_setup()
	for connection: Dictionary in closed.get_connections():
		connection.signal.disconnect(connection.callable)
	return closed


func defocus_element():
	_close_inventory()


func is_open() -> bool:
	return visible

func opening_setup():
	analysis_shown = false
	update_analysis()

	inventory_comp.access_entity()
	inventory_comp.slots_updated.connect(update_modslots_counter)

	update_inventory_list()
	inventory_comp.scraps_changed.connect(
			func(_prev_value, new_value): update_scrap_counter(new_value))

	modslot_comp = inventory_comp.get_slots_comp()
	update_modslotcomp_list()

	if inventory_comp.is_entity_turret():
		target_display_anim.play("turret")
	else:
		target_display_anim.play("player")
	disassemble_button.visible = inventory_comp.is_entity_turret()

	checking_blueprints = false
	selected_blueprint = null
	update_blueprint_list()
	crafting_inputs = []
	crafting_output = null
	update_crafting()


func _close_inventory():
	if not is_open():
		return

	if dragged_item != null:
		inventory_comp.add_mod(dragged_item)
	visible = false
	if crafting_inputs.size() > 0:
		for i in crafting_inputs:
			inventory_comp.add_mod(i)
		crafting_inputs = []
	can_affect_filter.close_dropdown()
	component_filter.close_dropdown()
	inventory_comp.slots_updated.disconnect(update_modslots_counter)
	inventory_comp.unaccess_entity()
	closed.emit()

func update_scrap_counter(scrap: int) -> void:
	scrap_counter_label.text = str(scrap)

func update_modslots_counter(mods: int, capacity: int) -> void:
	mod_slot_size_label.text = "%d/%d M.O.D.s equipped" % [mods, capacity]

func update_blueprint_list():
	for item in blueprint_list.get_children():
		item.free()

	for mod in inventory_comp.get_blueprints():
		if !mod_filter(mod): continue
		var blueprint = BLUEPRINT_CONTAINER.instantiate() as BlueprintContainer
		blueprint.mod = mod
		blueprint_list.add_child(blueprint)
		blueprint.update()
		blueprint.pressed.connect(blueprint_selected)
	blueprint_selected(selected_blueprint)

func blueprint_selected(selection: Mod):
	var prev_selected_blueprint_index = blueprint_list.get_children().find_custom(
		func(blueprint): return blueprint.mod == selected_blueprint)
	var curr_selected_blueprint_index = blueprint_list.get_children().find_custom(
		func(blueprint): return blueprint.mod == selection)
	if curr_selected_blueprint_index == -1: return
	if selection == selected_blueprint:
		if blueprint_list.get_children()[curr_selected_blueprint_index].selected:
			checking_blueprints = false
		else:
			blueprint_list.get_children()[curr_selected_blueprint_index].set_selected(true)
	else:
		blueprint_list.get_children()[prev_selected_blueprint_index].set_selected(false)
		blueprint_list.get_children()[curr_selected_blueprint_index].set_selected(true)
		selected_blueprint = selection
	blueprint_label.text = blueprint_list.get_children()[curr_selected_blueprint_index].get_mod_name()
	crafting_output = inventory_comp.get_blueprints()[curr_selected_blueprint_index]
	update_inventory_list()
	update_crafting_components()

func update_inventory_list():
	update_scrap_counter(inventory_comp.get_scraps())
	if checking_blueprints:
		blueprint_button_description.text = ""
		blueprint_button_description.size = Vector2(0, 0)
		blueprint_description_panel.size = Vector2(0, 0)
		blueprint_button_description.text = "[i]View Inventory[/i]"
		inventory_scroll.visible = false
		blueprint_scroll.visible = true
		inventory_mod_counter.text = "%d M.O.D. options" % (inventory_comp.get_blueprints().size() - 1)
	else:
		blueprint_button_description.text = ""
		blueprint_button_description.size = Vector2(0, 0)
		blueprint_description_panel.size = Vector2(0, 0)
		blueprint_button_description.text = "[i]View M.O.D.\nblueprints[/i]"
		inventory_scroll.visible = true
		blueprint_scroll.visible = false

		var mod_array = inventory_comp.get_mods()
		for item in inventory_list.get_children():
			item.queue_free()
		var total = 0
		for mod in mod_array:
			if mod_array[mod] <= 0 or !mod_filter(mod): continue
			var item = ITEM_CONTAINER.instantiate()
			item.mod = mod
			item.state = ItemContainer.State.INVENTORY
			item.count = mod_array[mod]
			total += item.count
			inventory_list.add_child(item)
			item.update()
			item.create_dragged_item.connect(add_dragged_item)
		inventory_mod_counter.text = "%d unique M.O.D.s, %d in total" % [mod_array.size(), total]

func mod_filter(mod: Mod) -> bool:
	var success: bool = true
	if search_bar.text != "":
		if mod == null:
			success = false
		elif !mod.name.containsn(search_bar.text):
			success = false
	if can_affect_filter.get_state() != DropdownCheckboxesContainer.State.ALL_SELECTED:
		if mod == null:
			success = false
		else:
			match (mod.type):
				Mod.Type.UPGRADE:
					for upgrade in mod.upgrades:
						if !can_affect_filter.get_selected()[upgrade.get_target()]: success = false
				Mod.Type.EFFECT:
					if !can_affect_filter.get_selected()[3]: success = false
				Mod.Type.BEHAVIOURAL:
					pass
	if component_filter.get_state() != DropdownCheckboxesContainer.State.ALL_SELECTED:
		if mod == null:
			success = false
		else:
			for pp in mod.property_points:
				if mod.property_points[pp] <= 0: continue
				var index = component_filter.items.find_custom(func(item): return item.icon == pp.icon)
				if !component_filter.get_selected()[index]: return false
	return success

func update_modslotcomp_list():
	var mod_array := inventory_comp.get_slots_mods()
	update_modslots_counter(mod_array.size(), modslot_comp.get_capacity())

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
		inventory_comp.get_slots_upgrade_cost(),
		SCRAP_EMOJI]

	if inventory_comp.can_upgrade_slots():
		upgrade_button.disabled = false
	else:
		upgrade_button.disabled = true

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
	crafting_scraps = (crafting_inputs
			.reduce(func(acc: int, mod: Mod): return acc + mod.get_recycle_value(), 0))
	for mod in crafting_inputs:
		for pp in mod.property_points:
			_crafting_components[pp] = _crafting_components.get_or_add(pp, 0) + mod.property_points[pp]
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
			if crafting_scraps + inventory_comp.get_scraps() >= crafting_output.value:
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
					crafting_output.value - (crafting_scraps + inventory_comp.get_scraps()),
					SCRAP_EMOJI
				]

func set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int):
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)


func _on_more_info_button_pressed() -> void:
	analysis_shown = !analysis_shown
	update_analysis()

func update_analysis():
	if !analysis_shown:
		target_display_label.text = (
			"[color=#46cd6d]Press [img=24]%s[/img] for analysis[/color]" % INFO_ICON)
		target_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		target_display_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		target_display_label.text = (
			"[color=#46cd6d]%s[/color]" % inventory_comp._entity.get_analysis())
		target_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		target_display_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _on_disassemble_button_pressed() -> void:
	inventory_comp.disassemble_turret()
	_close_inventory()

func add_dragged_item(item: DraggedItem, state: ItemContainer.State):
	add_child(item)
	dragged_item = item.mod
	item.dropped.connect(insert_item)
	match (state):
		ItemContainer.State.MODCOMP:
			modslot_comp.remove_mod(item.mod)
			update_modslotcomp_list()
		ItemContainer.State.INVENTORY:
			inventory_comp.remove_mod(item.mod)
			update_inventory_list()
		ItemContainer.State.CRAFTING:
			crafting_inputs.erase(item.mod)
			update_crafting()
	if analysis_shown:
		update_analysis()

func insert_item(mod: Mod, destination: ItemContainer.State):
	dragged_item = null
	match (destination):
		ItemContainer.State.MODCOMP:
			if modslot_comp.add_mod(mod):
				update_modslotcomp_list()
				audio.play_place_item()
			else:
				audio.play_fail()
				inventory_comp.add_mod(mod)
				update_inventory_list()

		ItemContainer.State.INVENTORY:
			audio.play_place_item()
			inventory_comp.add_mod(mod)
			update_inventory_list()

		ItemContainer.State.CRAFTING:
			audio.play_place_item()
			crafting_inputs.append(mod)
			update_crafting()

	update_analysis()


func _on_upgrade_button_pressed() -> void:
	if inventory_comp.upgrade_slots():
		update_modslotcomp_upgrade()


func _on_blueprints_button_pressed() -> void:
	checking_blueprints = !checking_blueprints
	update_inventory_list()


func _on_craft_button_pressed() -> void:
	if scrap_diff < 0:
		inventory_comp.use_scraps(-scrap_diff)
	else:
		inventory_comp.register_item(Item.ScrapItem.new(scrap_diff))
	if crafting_output != null:
		crafting_inputs = [crafting_output]
	else:
		crafting_inputs = []
	checking_blueprints = false
	update_crafting()
	blueprint_selected(null)
	particles.emitting = true
	audio.play_success()


func _on_search_bar_text_changed(_new_text: String) -> void:
	update_inventory_list()
	update_blueprint_list()


func _on_can_affect_filter_updated() -> void:
	update_inventory_list()
	update_blueprint_list()


func _on_component_filter_updated() -> void:
	update_inventory_list()
	update_blueprint_list()
