class_name Enemy
extends RigidBody2D

signal entity_spawned(Node2D)

const _LOOT_SCENE = preload("res://scenes/loot.tscn")

@export var health_prop: HealthProp
@export var movement_comp: MovementBaseComp

@onready var visuals := $Visuals as EnemyVisuals


func _ready() -> void:
	health_prop.emptied.connect(die)

func die():
	if not is_multiplayer_authority():
		return

	await visuals.bleed_finished
	get_parent().remove_entity(self)

	var loot = _LOOT_SCENE.instantiate()
	loot.setup_scrap_loot(1)
	loot.global_position = global_position
	entity_spawned.emit(loot)

func deactivate():
	movement_comp.active = false


#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
