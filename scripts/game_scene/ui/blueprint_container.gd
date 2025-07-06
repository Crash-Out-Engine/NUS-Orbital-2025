class_name BlueprintContainer
extends PanelContainer

signal pressed(mod: Mod)

const _DRAGGED_ITEM = preload("res://scenes/dragged_item.tscn")

@export var mod: Mod = null

var selected: bool = false
var mouse_hovering = false

@onready var name_label = $RichTextLabel as RichTextLabel
@onready var description = $Description as Control
@onready var description_panel = $Description/Panel as PanelContainer
@onready var description_label = $Description/Panel/RichTextLabel as RichTextLabel

func update():
	name_label.text = get_mod_name()
	description_label.text = get_description()

func _process(_delta: float) -> void:
	if mouse_hovering:
		description_panel.global_position = get_global_mouse_position()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		pressed.emit(mod)

func get_mod_name() -> String:
	if mod == null:
		return "[i]Recycle for scraps[/i][img=36]res://resources/text_icons/scrap_icon.tres[/img]"
	return "%s [i]%s[/i]" % [mod.get_icon(36), mod.name]

func _on_mouse_entered() -> void:
	mouse_hovering = true
	if mod == null: return
	description.visible = true

func set_selected(value: bool):
	if value:
		selected = true
		self_modulate.v = 0.66
	else:
		selected = false
		self_modulate.v = 1

func get_description():
	if mod == null:
		return ""
	var paragraph: String = "%s:\n%s\nRequires:" % [mod.name, mod.description]
	paragraph += (
		"\n%d[img={24}]res://resources/text_icons/scrap_icon.tres[/img]" % mod.value)
	for pp in mod.property_points:
		paragraph += ", %s×%d" % [pp.get_icon(), mod.property_points[pp]]
	return paragraph


func _on_mouse_exited() -> void:
	description.visible = false
	mouse_hovering = false
