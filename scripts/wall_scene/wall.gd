class_name Wall
extends StaticBody2D

@export_group("Properties")
@export var health: HealthProp

var size: Vector2:
	set(value):
		if value != size:
			$Visuals/Polygon2D.scale = value
			$CollisionShape2D.shape = RectangleShape2D.new()
			$CollisionShape2D.shape.size = value


func _ready() -> void:
	health.emptied.connect(_die)


func _die() -> void:
	get_parent().server_remove_entity(self)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict := {}
	dict["position"] = position
	dict["size"] = size
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)


func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data) as Dictionary
	position = dict["position"]
	size = dict["size"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])


func load_preset(preset: WallPreset) -> void:
	position = preset.position
	size = preset.size
	health.value = preset.health

#endregion
