extends MarginContainer

signal recipe_selected(recipe: Crafting_Recipe)

@export var recipe: Crafting_Recipe

@onready var input_icon = $PanelContainer/MarginContainer/HBoxContainer/InputIcon as Sprite2DRect
@onready var input_plus = $PanelContainer/MarginContainer/HBoxContainer/InputPlus as TextureRect
@onready var input_scrap = $PanelContainer/MarginContainer/HBoxContainer/InputScrap as TextureRect
@onready var input_scrap_label = (
	$PanelContainer/MarginContainer/HBoxContainer/InputScrap/Label as Label)
@onready var output_icon = $PanelContainer/MarginContainer/HBoxContainer/OutputIcon as Sprite2DRect
@onready var output_plus = $PanelContainer/MarginContainer/HBoxContainer/OutputPlus as TextureRect
@onready var output_scrap = (
	$PanelContainer/MarginContainer/HBoxContainer/OutputScrap as TextureRect)
@onready var output_scrap_label = (
	$PanelContainer/MarginContainer/HBoxContainer/OutputScrap/Label as Label)
@onready var button = $Button as Button

func update():
	input_icon.Frame = recipe.input.icon_id
	if recipe.scrap_change < 0:
		input_plus.visible = true
		input_scrap.visible = true
		input_scrap_label.text = str(recipe.scrap_change)
		output_plus.visible = false
		output_scrap.visible = false
	elif recipe.scrap_change > 0:
		output_plus.visible = recipe.output != null
		output_scrap.visible = true
		output_scrap_label.text = str(recipe.scrap_change)
		input_plus.visible = false
		input_scrap.visible = false
	else:
		input_plus.visible = false
		input_scrap.visible = false
		output_scrap.visible = false
		output_plus.visible = false
	if recipe.output == null:
		output_icon.visible = false
	else:
		output_icon.visible = true
		output_icon.Frame = recipe.output.icon_id
	button.disabled = !recipe.unlocked


func _on_button_pressed() -> void:
	recipe_selected.emit(recipe)
