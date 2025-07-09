class_name Wall
extends StaticBody2D

@export_group("Properties")
@export var health: HealthProp


func _ready() -> void:
	health.emptied.connect(_die)


func _die() -> void:
	get_parent().server_remove_entity(self)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict := {}
	dict["global_position"] = global_position
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)


func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data) as Dictionary
	global_position = dict["global_position"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
