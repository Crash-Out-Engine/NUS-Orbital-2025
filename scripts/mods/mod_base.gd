class_name ModBase
extends Resource

enum Type {
	BEHAVIOURAL,
	EFFECT,
	UPGRADE,
}

@export var name: String
@export var icon: AtlasTexture
@export var description: String
@export var property_points: Dictionary[PropertyPoint, int]
@export var value: int

var type: Type

func _init() -> void:
	assert(false, "ModBase is an abstract class and cannot be instantiated.")

func get_icon(size: int = 24):
	return ("[img={%d}]" % size) + icon.resource_path + "[/img]"

func get_recycle_value() -> int:
	return int(float(value) * 0.8)

#region Save/load

func save() -> PackedByteArray:
	return var_to_bytes(resource_path)

static func from_saved(data: PackedByteArray) -> ModBase:
	var path = bytes_to_var(data)
	return ResourceLoader.load(path) as ModBase
