class_name Selectable
extends Resource

signal updated()

@export var text: String
@export var icon: Texture2D
@export var selected: bool:
	set(value):
		selected = value
		updated.emit()
