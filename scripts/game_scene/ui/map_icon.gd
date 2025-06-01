class_name MapIcon
extends Sprite2D

enum Icon { # Based on icon position in the texture, should be edited when texture is edited.
	EMPTY,
	PLAYER,
	FAULT,
	PLANNED_TURRET,
	BUILT_TURRET,
}

func swap(icon: Icon) -> void:
	frame = icon
