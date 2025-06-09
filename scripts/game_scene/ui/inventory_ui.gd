extends Control

const _ITEM_CONTAINER = preload("res://scenes/item_container.tscn")
const _RECIPE_CONTAINER = preload("res://scenes/recipe_container.tscn")

@export var player : Player
@export var crafting_recipes: Array[CraftingRecipe]

var inventory_comp : InventoryComp
var modslot_comp : ModSlotComp
var crafting_input : ModBase = null
var current_recipe : CraftingRecipe = null
var turret : Turret = null

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
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/UpgradeButton/Margin/HBox/Label as Label)
@onready var inventory_mod_counter = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryModCounter as Label)
@onready var modcomp_list = (
	$Margin/PanelContainer/HBox/LeftVBox/ModSlotList/VBox/ScrollContainer/VBox as Container)
@onready var inventory_list = (
	$Margin/PanelContainer/HBox/MidVBox/PanelContainer/VBox/InventoryList/Margin/VBox as Container)
@onready var crafting_slot_graphic = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftingSlotGraphic as Sprite2DRect)
@onready var crafting_slot_margins = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftingSlotGraphic/Margin as MarginContainer)
@onready var crafting_input_container = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftingSlotGraphic/Margin/CraftInput
	as Container)
@onready var crafting_output_container = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftingSlotGraphic/Margin/CraftOutput
	as Container)
@onready var crafting_button = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftButton as Button)
@onready var crafting_button_label_box = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftButton/Margin/HBox as HBoxContainer)
@onready var crafting_button_label = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftButton/Margin/HBox/Label as Label)
@onready var crafting_instructions_label = (
	$Margin/PanelContainer/HBox/RightVBox/Crafting/VBox/CraftingSlotGraphic/Label as Label)
@onready var recipe_list = (
	$Margin/PanelContainer/HBox/RightVBox/CraftOptions/RecipeList/VBox as VBoxContainer)
@onready var analysis = $Analysis as Container
@onready var analysis_label = $Analysis/PanelContainer/Label as Label

func _ready() -> void:
	visible = false
	player.inform_inventory.connect(opening_setup)

func try_open():
	if Input.is_action_just_pressed("inventory"):
		analysis.visible = false
		if visible:
			close_inventory()
		else:
			visible = true

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
		modslot_comp = modslot_input
		update_modslotcomp_list()
		modslot_comp.modslots_updated.connect(update_modslots_counter)

		if modslot_comp.get_parent().get_parent() is Turret:
			turret = modslot_comp.get_parent().get_parent()
		else:
			turret = null
		target_display.Frame = 0 if turret == null else 1
		disassemble_button.visible = !(turret == null)

	crafting_input = null
	update_crafting_slot()
	player.open_inventory()

func force_close():
	close_inventory()

func close_inventory():
	analysis.visible = false
	visible = false
	if crafting_input != null:
		inventory_comp._add_mod(crafting_input)
		update_inventory_list()
	player.close_inventory()

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

	update_modslotcomp_upgrade()

func update_modslotcomp_upgrade():
	upgrade_button_label.text = "Add slot(%d" % modslot_comp.get_upgrade_cost()
	if modslot_comp.get_upgrade_cost() > player.get_scraps():
		upgrade_button.disabled = true
	else:
		upgrade_button.disabled = false

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
		crafting_instructions_label.visible = false
		crafting_button_label_box.visible = true
	else:
		crafting_instructions_label.visible = true
		crafting_slot_graphic.Frame = 0
		set_margins(crafting_slot_margins, 0, 0, 0, 0)
		crafting_input_container.visible = false
		crafting_output_container.visible = false
		crafting_button_label_box.visible = false
		crafting_button.disabled = true
	update_recipes_list()

func update_recipes_list():
	for recipe in recipe_list.get_children():
		recipe.queue_free()
	current_recipe = null
	if crafting_input != null:
		var valid_recipes = crafting_recipes.filter(func(recipe): return recipe.input == crafting_input)
		for recipe in valid_recipes:
			var recipe_container = _RECIPE_CONTAINER.instantiate()
			recipe_container.recipe = recipe
			recipe_list.add_child(recipe_container)
			recipe_container.update()
			recipe_container.recipe_selected.connect(set_current_recipe)
			if recipe == valid_recipes[0]:
				recipe_container.button.pressed.emit()
				recipe_container.button.grab_focus()

func update_crafting_recipe_slot():
	if current_recipe.output == null:
		crafting_slot_graphic.Frame = 1
		set_margins(crafting_slot_margins, 194, 36, 194, 36)
		crafting_input_container.visible = true
		crafting_output_container.visible = false
		crafting_button_label.text = "Recycle! (+%d" % current_recipe.scrap_change
		crafting_button.disabled = false
	else:
		crafting_slot_graphic.Frame = 2
		set_margins(crafting_slot_margins, 36, 36, 36, 36)
		crafting_input_container.visible = true
		crafting_output_container.visible = true

		var output = _ITEM_CONTAINER.instantiate()
		output.mod = current_recipe.output
		output.state = ItemContainer.State.CRAFTING
		output.set_grabbable(false)
		crafting_output_container.add_child(output)
		output.update()

		if -current_recipe.scrap_change <= player.get_scraps():
			crafting_button_label.text = "Craft! (Cost:%d" % current_recipe.scrap_change
			crafting_button.disabled = false
		else:
			crafting_button_label.text = "(Need %d" % current_recipe.scrap_change
			crafting_button.disabled = true

func set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int):
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)

func set_current_recipe(recipe: CraftingRecipe):
	current_recipe = recipe
	update_crafting_recipe_slot()

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
			crafting_input = null
			update_crafting_slot()

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
			crafting_input = mod
			update_crafting_slot()


func _on_craft_button_pressed() -> void:
	crafting_input = current_recipe.output
	if current_recipe.scrap_change < 0:
		player.use_scraps(-current_recipe.scrap_change)
	elif current_recipe.scrap_change > 0:
		player.inventory.register_item(Item.ScrapItem.new(current_recipe.scrap_change))
	update_crafting_slot()


func _on_upgrade_button_pressed() -> void:
	player.use_scraps(modslot_comp.get_upgrade_cost())
	modslot_comp.change_capcity(1)
