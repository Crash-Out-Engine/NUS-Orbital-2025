class_name DraggedItem
extends Area2D

signal dropped(mod: ModBase, destination: ItemContainer.State)

@export var mod: ModBase
@export var destination: ItemContainer.State

@onready var icon = $Panel/TextureRect as TextureRect

func update():
	icon.texture = mod.icon

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("LMB"):
		dropped.emit(mod, destination)
		queue_free()
		get_viewport().set_input_as_handled()


func _on_area_entered(area: Area2D) -> void:
	if area is ItemDropArea:
		destination = area.get_destination()
