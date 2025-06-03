class_name Item
extends Resource

enum Type {
	SCRAP,
	MOD,
}

var type: Type


class ScrapItem:
	extends Item

	var count: int

	func _init(_count: int) -> void:
		type = Type.SCRAP
		count = _count


class ModItem:
	extends Item

	var mod: ModBase

	func _init(_mod: ModBase) -> void:
		mod = _mod

