class_name Enemy
extends RigidBody2D

signal entity_spawned(Node2D)

enum Type {
	MELEE,
	RANGED
}

const _LOOT_SCENE = preload("res://scenes/loot.tscn")

@export var health_prop: HealthProp
@export var movement_comp: MovementBaseComp
@export var ranged_comp: RangedAIComp
@export var modslot_comp: ModSlotComp

var type: Type

@onready var visuals := $Visuals as EnemyVisuals


func _ready() -> void:
	match type:
		Type.MELEE:
			ranged_comp.active = false
		Type.RANGED:
			ranged_comp.active = true
			ranged_comp.bullet_spawned.connect(entity_spawned.emit)
	health_prop.emptied.connect(die)

func add_mod(mod: ModBase):
	modslot_comp.add_mod(mod)

func die():
	if not is_multiplayer_authority():
		return

	await visuals.bleed_finished
	get_parent().remove_entity(self)

	var loot = _LOOT_SCENE.instantiate()
	loot.setup_scrap_loot(modslot_comp.get_mods().size() + type - 1)
	loot.global_position = global_position
	entity_spawned.emit(loot)
	var rng = RandomNumberGenerator.new()
	for i in range(2, modslot_comp.get_mods().size()):
		if rng.randf() < 0.25: #HACK: to implement proper loot drop chances
			var mod = _LOOT_SCENE.instantiate()
			mod.setup_mod_loots(modslot_comp.get_mods()[i])
			mod.global_position = global_position
			entity_spawned.emit(mod)

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
