class_name Enemy
extends RigidBody2D

signal entity_spawned(entity: Node2D)

enum Type {
	MELEE,
	RANGED,
	MINI,
	BERSERKER,
	SNIPER,
	KAMIKAZE,
	SUPPORT
}

const _LOOT_SCENE = preload("res://scenes/loot.tscn")

@export var health_prop: HealthProp
@export var movement_comp: MovementBaseComp
@export var ranged_comp: RangedAIComp
@export var modslot_comp: ModSlotComp

var type: Type

@onready var visuals := $Visuals as EnemyVisuals
@onready var hitbox_collision_shape := $HitboxCollisionShape as CollisionShape2D
@onready var head_hurtbox := $Components/MeleeComp/HeadCollisionShape as CollisionShape2D
@onready var body_hurtbox := $Components/MeleeComp/BodyCollisionShape as CollisionShape2D

func _ready() -> void:
	match type:
		Type.MELEE:
			ranged_comp.active = false
			body_hurtbox.position.y = 11
		Type.RANGED:
			ranged_comp.active = true
			ranged_comp.bullet_spawned.connect(entity_spawned.emit)
			body_hurtbox.position.y = 11
			add_mod(preload("res://resources/mods/enemy_default_mods/enemy_damage.tres"))
			add_mod(preload("res://resources/mods/enemy_default_mods/enemy_bullet.tres"))
		Type.MINI:
			ranged_comp.active = false
			hitbox_collision_shape.shape = load(
				"res://resources/collision_shapes/mini_enemy_hitbox.tres")
			head_hurtbox.shape = load("res://resources/collision_shapes/mini_enemy_head.tres")
			body_hurtbox.shape = load("res://resources/collision_shapes/mini_enemy_body.tres")
			body_hurtbox.position.y = 9.5
			$Properties/SpeedProp.value *= 1.5
		Type.BERSERKER:
			ranged_comp.active = false
			hitbox_collision_shape.shape = load(
				"res://resources/collision_shapes/berserker_enemy_hitbox.tres")
			head_hurtbox.shape = load("res://resources/collision_shapes/berserker_enemy_head.tres")
			body_hurtbox.disabled = true
			$Properties/SpeedProp.value *= 4
			$Properties/HealthCapacityProp.value *= 5
			$Properties/HealthProp.value *= 5
		Type.SNIPER:
			ranged_comp.active = true
			ranged_comp.bullet_spawned.connect(entity_spawned.emit)
			body_hurtbox.disabled = true
			$Properties/SpeedProp.value = 0
			add_mod(preload("res://resources/mods/enemy_default_mods/sniper_enemy.tres"))
		Type.KAMIKAZE:
			ranged_comp.active = true
			ranged_comp.bullet_spawned.connect(entity_spawned.emit)
			body_hurtbox.position.y = 11
			$Properties/SpeedProp.value *= 2.5
			ranged_comp.bullet_target_filter.targets.append(Enums.Team.ENEMY)
			add_mod(preload("res://resources/mods/enemy_default_mods/kamikaze_enemy.tres"))
	health_prop.emptied.connect(die)

func add_mod(mod: Mod):
	modslot_comp.add_mod(mod)

func die():
	if not is_multiplayer_authority():
		return

	await visuals.bleed_finished
	get_parent().server_remove_entity(self)

	var loot = _LOOT_SCENE.instantiate()
	loot.setup_scrap_loot(modslot_comp.get_mods().size() + type - 1)
	loot.global_position = global_position
	entity_spawned.emit(loot)
	var rng = RandomNumberGenerator.new()
	for i in range(2, modslot_comp.get_mods().size()):
		if rng.randf() < 0.25: #HACK: to implement proper loot drop chances
			var mod = _LOOT_SCENE.instantiate()
			mod.setup_mod_loot(modslot_comp.get_mods()[i])
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
