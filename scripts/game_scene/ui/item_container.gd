class_name ItemContainer
extends PanelContainer

signal create_dragged_item(item: DraggedItem, state: State)

enum State {
	MODCOMP,
	INVENTORY,
	CRAFTING
}

const _DRAGGED_ITEM = preload("res://scenes/UI/dragged_item.tscn")

@export var mod: Mod
@export var count: int
@export var state: State

var grabbable: bool = true
var mouse_hovering = false

@onready var name_label = $RichTextLabel as RichTextLabel
@onready var count_label = $Control/CountLabel as Label
@onready var description = $Description as Control
@onready var description_panel = $Description/Panel as PanelContainer
@onready var description_label = $Description/Panel/RichTextLabel as RichTextLabel

func update():
	name_label.text = mod.get_icon(36) + mod.name

	match state:
		State.MODCOMP:
			name_label.visible = true
			count_label.visible = false
		State.INVENTORY:
			name_label.visible = true
			count_label.text = str(count)
			count_label.visible = true
		State.CRAFTING:
			name_label.visible = true
			count_label.visible = false

	description_label.text = get_description()

func _process(_delta: float) -> void:
	if mouse_hovering:
		description_panel.global_position = get_global_mouse_position()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and mouse_hovering and grabbable:
		var item = _DRAGGED_ITEM.instantiate()
		item.mod = mod
		item.destination = state
		create_dragged_item.emit(item, state)
		item.update()
		description.visible = false
		mouse_hovering = false

func _on_mouse_entered() -> void:
	description.visible = true
	mouse_hovering = true

func set_grabbable(value: bool):
	grabbable = value

func get_description():
	var paragraph: String = "%s:\n%s\nComponents:" % [mod.name, mod.description]
	var first = true
	for pp in mod.property_points:
		if first:
			first = false
		else:
			paragraph += ", "
		paragraph += "%s×%d" % [pp.get_icon(), mod.property_points[pp]]
	paragraph += (
		"\nScrap value:%d[img={24}]res://resources/text_icons/scrap_icon.tres[/img]" % mod.value)

	return paragraph


func _on_mouse_exited() -> void:
	description.visible = false
	mouse_hovering = false
