class_name LootCrate
extends StaticBody2D

signal entity_spawned(entity: Node2D)

const _LOOT_SCENE := preload("res://scenes/loot.tscn")

@export_group("Properties")
@export var health: HealthProp


func _ready() -> void:
	health.emptied.connect(_die)


func _die() -> void:
	if not is_multiplayer_authority():
		return

	var loot = _LOOT_SCENE.instantiate()
	loot.setup_scrap_loot(randi_range(1, 5)) # TODO: Implement proper loot drop chances.
	loot.position = position
	entity_spawned.emit(loot)
	get_parent().server_remove_entity(self)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict := {}
	dict["position"] = position
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)


func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data) as Dictionary
	position = dict["position"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])


func load_preset(preset: LootCratePreset) -> void:
	position = preset.position

#endregion
