class_name LootCrate
extends StaticBody2D

signal entity_spawned(entity: Node2D)

enum Type {
	SMALL_CRATE,
	SMALL_CRATE_OPEN,
	MEDIUM_CRATE,
	MEDIUM_CRATE_OPEN,
	BURIED
}

const _LOOT_SCENE := preload("res://scenes/loot.tscn")
const _CRATE_SIZE := [
	Vector2(20, 20),
	Vector2(20, 20),
	Vector2(32, 24),
	Vector2(32, 24),
	Vector2(28, 18)
]

@export_group("Properties")
@export var health: HealthProp

var type: Type = Type.MEDIUM_CRATE_OPEN

@onready var hitbox := $CollisionShape2D as CollisionShape2D
@onready var sprite := $Visuals/Sprite2D as Sprite2D

func _ready() -> void:
	health.emptied.connect(_die)
	match(type):
		Type.SMALL_CRATE:
			sprite.frame = 0
			health._initial_health = 40
			health.value = 40
		Type.SMALL_CRATE_OPEN:
			sprite.frame = 1
			health._initial_health = 20
			health.value = 20
		Type.MEDIUM_CRATE:
			sprite.frame = 4
			health._initial_health = 60
			health.value = 60
		Type.MEDIUM_CRATE_OPEN:
			sprite.frame = 5
			health._initial_health = 20
			health.value = 20
		Type.BURIED:
			sprite.frame = 2
			health._initial_health = 80
			health.value = 80
			set_collision_layer_value(1, false)
	hitbox.shape.size = _CRATE_SIZE[type as int]


func _die() -> void:
	if not is_multiplayer_authority():
		return

	var loots: Array[Loot]
	match type:
		Type.SMALL_CRATE:
			var scrap_loot = _LOOT_SCENE.instantiate()
			scrap_loot.setup_scrap_loot(randi_range(1, 5))
			loots.append(scrap_loot)
			if randf() > 0.9:
				var mod_loot = _LOOT_SCENE.instantiate()
				mod_loot.setup_mod_loot(
					load(Mod.MOD_LIST[randi_range(0, Mod.MOD_LIST.size() - 1)]))
				loots.append(mod_loot)
		Type.SMALL_CRATE_OPEN:
			var scrap_loot = _LOOT_SCENE.instantiate()
			scrap_loot.setup_scrap_loot(randi_range(2, 8))
			loots.append(scrap_loot)
		Type.MEDIUM_CRATE:
			var scrap_loot = _LOOT_SCENE.instantiate()
			scrap_loot.setup_scrap_loot(randi_range(5, 15))
			loots.append(scrap_loot)
			match randi_range(0, 4):
				0:
					var mod_loot = _LOOT_SCENE.instantiate()
					mod_loot.setup_mod_loot(
						load(Mod.MOD_LIST[randi_range(0, Mod.MOD_LIST.size() - 1)]))
					loots.append(mod_loot)
				1:
					var blueprint_loot = _LOOT_SCENE.instantiate()
					blueprint_loot.setup_blueprint_loot(
						load(Mod.MOD_LIST[randi_range(0, Mod.MOD_LIST.size() - 1)]))
					loots.append(blueprint_loot)
				_:
					pass
		Type.MEDIUM_CRATE_OPEN:
			var scrap_loot = _LOOT_SCENE.instantiate()
			scrap_loot.setup_scrap_loot(randi_range(12, 18))
			loots.append(scrap_loot)
		Type.BURIED:
			var scrap_loot = _LOOT_SCENE.instantiate()
			scrap_loot.setup_scrap_loot(randi_range(15, 20))
			loots.append(scrap_loot)

	for loot in loots:
		loot.position = position
		entity_spawned.emit(loot)
	get_parent().server_remove_entity(self)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict := {}
	dict["position"] = position
	dict["type"] = type
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)


func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data) as Dictionary
	position = dict["position"]
	type = dict["type"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
