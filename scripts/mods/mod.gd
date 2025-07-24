class_name Mod
extends Resource

const MOD_LIST := [
	"res://resources/mods/effect_mods/base_damage.tres",
	"res://resources/mods/effect_mods/base_damage_over_time.tres",
	"res://resources/mods/effect_mods/base_increase_ranged_cooldown.tres",
	"res://resources/mods/effect_mods/base_knockback.tres",
	"res://resources/mods/effect_mods/base_slowdown.tres",
	"res://resources/mods/sidegrade_mods/grenade_launcher_sidegrade.tres",
	"res://resources/mods/sidegrade_mods/minigun_sidegrade.tres",
	"res://resources/mods/sidegrade_mods/revolver_sidegrade.tres",
	"res://resources/mods/sidegrade_mods/rocket_launcher_sidegrade.tres",
	"res://resources/mods/sidegrade_mods/shotgun_sidegrade.tres",
	"res://resources/mods/sidegrade_mods/sniper_sidegrade.tres",
	"res://resources/mods/upgrade_mods/base_bullet_count_upgrade.tres",
	"res://resources/mods/upgrade_mods/base_explosion_count_upgrade.tres",
	"res://resources/mods/upgrade_mods/base_explosion_size_upgrade.tres",
	"res://resources/mods/upgrade_mods/base_health_capacity_upgrade.tres",
	"res://resources/mods/upgrade_mods/base_melee_cooldown_upgrade.tres",
	"res://resources/mods/upgrade_mods/base_ranged_cooldown_upgrade.tres",
	"res://resources/mods/upgrade_mods/base_speed_upgrade.tres",
	"res://resources/mods/upgrade_mods/decrease_bullet_spread_upgrade.tres",
	"res://resources/mods/upgrade_mods/enlargement_upgrade.tres",
	"res://resources/mods/upgrade_mods/extra_life_upgrade.tres",
	"res://resources/mods/upgrade_mods/increase_bullet_spread_upgrade.tres",
	"res://resources/mods/upgrade_mods/increase_explosion_size_upgrade.tres",
	"res://resources/mods/upgrade_mods/larger_bullet_upgrade.tres",
	"res://resources/mods/upgrade_mods/piercing_upgrade.tres",
	"res://resources/mods/upgrade_mods/repeat_explosion_upgrade.tres",
	"res://resources/mods/upgrade_mods/shrink_upgrade.tres"
]

@export var name: String
@export var icon: AtlasTexture
@export var description: String
@export var property_points: Dictionary[PropertyPoint, int]
@export var value: int
@export var entries: Array[ModEntry]


static func compile_entries(mods: Array[Mod]) -> Array[ModEntry]:
	var array: Array[ModEntry]
	for mod in mods:
		array.append_array(mod.entries)
	return array


static func compile_effects(mods: Array[Mod]) -> Array[Effect]:
	var array: Array[Effect]
	for mod in mods:
		array.append_array(mod.get_effects())
	return array


static func compile_upgrades(mods: Array[Mod], target: Upgrade.Target) -> Array[Upgrade]:
	var array: Array[Upgrade]
	for mod in mods:
		array.append_array(mod.get_upgrades(target))
	return array


func get_icon(size: int = 24):
	return ("[img={%d}]" % size) + icon.resource_path + "[/img]"

func get_recycle_value() -> int:
	return int(float(value) * 0.8)

func get_upgrades(target: Upgrade.Target) -> Array[Upgrade]:
	var array: Array[Upgrade]
	array.assign(
			entries.filter(
					func(entry): return entry.type == ModEntry.Type.UPGRADE and entry.get_target() == target
			)
	)
	return array

func get_effects() -> Array[Effect]:
	var array: Array[Effect]
	array.assign(entries.filter(func(entry): return entry.type == ModEntry.Type.EFFECT))
	return array

#region Save/load

func save() -> PackedByteArray:
	return var_to_bytes(resource_path)

static func from_saved(data: PackedByteArray) -> Mod:
	var path = bytes_to_var(data)
	return ResourceLoader.load(path) as Mod
