class_name ModBase
extends Resource

enum Type {
	APPLICATION,
	EFFECT,
	UPGRADE,
}

var type: Type


func _init() -> void:
	assert(false, "ModBase is an abstract class and cannot be initialized.")
