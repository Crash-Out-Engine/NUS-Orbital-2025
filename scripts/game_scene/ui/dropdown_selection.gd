class_name DropdownSelection
extends Button

const SELECTED_ICON = preload("res://resources/text_icons/radiobutton_selected.tres")
const DESELECTED_ICON = preload("res://resources/text_icons/radiobutton_deselected.tres")

@export var selectable: Selectable

func update():
	var icon_string = ""
	if selectable.icon != null:
		icon_string = "[img]" + selectable.icon.resource_path + "[/img]"
	$MarginContainer/RichTextLabel.text = icon_string + selectable.text
	update_radiobutton()

func update_radiobutton():
	if selectable.selected:
		icon = SELECTED_ICON
	else:
		icon = DESELECTED_ICON

func _on_pressed() -> void:
	selectable.selected = !selectable.selected
	update_radiobutton()
