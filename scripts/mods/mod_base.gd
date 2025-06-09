class_name ModBase
extends Resource

enum Type {
	APPLICATION,
	EFFECT,
	UPGRADE,
}

@export var name: String
@export var icon_id: int
@export var description: String

var type: Type

func _init() -> void:
	assert(false, "ModBase is an abstract class and cannot be instantiated.")
