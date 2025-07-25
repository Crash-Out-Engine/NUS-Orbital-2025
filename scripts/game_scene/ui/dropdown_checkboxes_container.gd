class_name DropdownCheckboxesContainer
extends PanelContainer

signal updated()

enum State {
	NONE_SELECTED,
	SOME_SELECTED,
	ALL_SELECTED
}

const SELECTION = preload("res://scenes/UI/DropdownSelection.tscn")

@export var title: String
@export var items: Array[Selectable]

var setup: bool = false

@onready var label = $SelectionButton/MarginContainer/HBoxContainer/Label as Label
@onready var selection_button = $SelectionButton as PanelContainer
@onready var dropdown_panel = $CanvasLayer/DropdownPanel as PanelContainer
@onready var dropdown_container = $CanvasLayer/DropdownPanel/VBox as VBoxContainer
@onready var all_selector = $CanvasLayer/DropdownPanel/VBox/DropdownSelection as DropdownSelection

func _ready() -> void:
	select_all()
	setup = false
	label.text = title
	all_selector.pressed.connect(unify_all)


func _input(event: InputEvent) -> void:
	if not dropdown_open():
		return

	if event.is_action_pressed("LMB"):
		if (!selection_button.get_global_rect().has_point(get_global_mouse_position())
				and !dropdown_panel.get_global_rect().has_point(get_global_mouse_position())):
			close_dropdown()


func get_selected() -> Array[bool]:
	var result: Array[bool] = []
	result.assign(items.map(func(selectable): return selectable.selected))
	return result

func unify_all():
	if get_state() == State.ALL_SELECTED:
		deselect_all()
		all_selector.selectable.text = "Select All"
	else:
		select_all()
		all_selector.selectable.text = "Deselect All"
	all_selector.update()
	updated.emit()

func select_all():
	for i in items:
		i.selected = true

func deselect_all():
	for i in items:
		i.selected = false

func update_items():
	for i in items:
		var selection = SELECTION.instantiate() as DropdownSelection
		selection.selectable = i
		dropdown_container.add_child(selection)
		selection.update()
		selection.pressed.connect(update_list)

func get_state() -> State:
	var none_selected = true
	var all_selected = true
	for i in items:
		if i.selected:
			none_selected = false
		else:
			all_selected = false
	if none_selected:
		return State.NONE_SELECTED
	if all_selected:
		return State.ALL_SELECTED
	return State.SOME_SELECTED

func set_up():
	dropdown_panel.size.x = selection_button.size.x
	dropdown_panel.global_position = selection_button.global_position
	dropdown_panel.global_position.y += selection_button.size.y
	update_items()
	setup = true

func _on_button_pressed() -> void:
	dropdown_panel.visible = !dropdown_panel.visible
	if !setup:
		set_up()

func dropdown_open() -> bool:
	return dropdown_panel.visible

func close_dropdown():
	dropdown_panel.visible = false

func update_list():
	if get_state() == State.ALL_SELECTED:
		all_selector.selectable.selected = true
		all_selector.selectable.text = "Deselect All"
	else:
		all_selector.selectable.selected = false
		all_selector.selectable.text = "Select All"
	all_selector.update()
	updated.emit()
