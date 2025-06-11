class_name ItemDropArea
extends Area2D

@export var item_state: ItemContainer.State

func get_destination():
	return item_state
