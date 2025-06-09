class_name ItemContainer
extends PanelContainer

signal create_dragged_item(item: DraggedItem, state: State)

enum State {
	MODCOMP,
	INVENTORY,
	CRAFTING
}

const _DRAGGED_ITEM = preload("res://scenes/dragged_item.tscn")

@export var mod: ModBase
@export var count: int
@export var state: State

var grabbable: bool = true
var mouse_hovering = false

@onready var icon = $HBoxContainer/Sprite2DRect as Sprite2DRect
@onready var name_label = $HBoxContainer/NameLabel as Label
@onready var count_label = $Control/CountLabel as Label
@onready var description = $Description as Control
@onready var description_panel = $Description/Panel as PanelContainer
@onready var description_label = $Description/Panel/Label as Label

func update():
	icon.Frame = mod.icon_id

	if state == State.CRAFTING:
		name_label.visible = false
	else:
		name_label.text = mod.name
		name_label.visible = true

	if state == State.INVENTORY:
		count_label.visible = true
		count_label.text = str(count)
	else:
		count_label.visible = false

	description_label.text = mod.description

func _process(_delta: float) -> void:
	if mouse_hovering:
		if Rect2(global_position, size).has_point(get_global_mouse_position()):
			description_panel.global_position = get_global_mouse_position()
			if Input.is_action_just_pressed("shoot") and grabbable:
				var item = _DRAGGED_ITEM.instantiate()
				item.mod = mod
				item.destination = state
				create_dragged_item.emit(item, state)
				item.update()
				description.visible = false
				mouse_hovering = false
		else:
			description.visible = false
			mouse_hovering = false
		#Description panel blocks ItemContainer from detecting the mouse

func _on_mouse_entered() -> void:
	description.visible = true
	mouse_hovering = true

func set_grabbable(value: bool):
	grabbable = value
