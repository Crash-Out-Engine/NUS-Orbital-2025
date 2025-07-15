class_name Bullet
extends Area2D

signal entity_spawned(entity: Node2D)

## The assumed speed of a bullet for predictive aiming.
const ASSUMED_SPEED := 800.0 # HACK: Should calculate speed based on initial mods.
const _EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")

@export_group("Properties")
@export var repeat_prop: RepeatProp
@export var size_prop: SizeProp
@export var copy_prop: CopyProp
@export var speed_prop: SpeedProp
@export var spread_prop: SpreadProp
@export var timeout_prop: TimeoutProp

@export_group("Components")
@export var bullet_mods_comp: BulletModsComp

var direction: float
var attack: Attack


func _ready() -> void:
	bullet_mods_comp.setup_mods()


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	global_position += Vector2.from_angle(direction) * speed_prop.value * delta
	global_rotation = direction


func get_speed() -> float:
	return speed_prop.value


func assign_mods(mods: Array[Mod]) -> void:
	bullet_mods_comp.mods.assign(mods)


func _on_body_entered(body: Node2D) -> void:
	if not is_multiplayer_authority():
		return

	if (body.has_node(^"Components/HitboxComp")
			and body.get_node(^"Components/HitboxComp").is_targeted_by(attack.target_filter)):
		var pos_offset = copy_prop.value * spread_prop.value * Vector2(1.0, 1.0) as Vector2
		var interval = 2 * PI / copy_prop.value
		for i in copy_prop.value:
			var explosion = _EXPLOSION_SCENE.instantiate()
			explosion.global_position = global_position + pos_offset.rotated(i * interval)
			explosion.assign_mods(bullet_mods_comp.mods)
			explosion.attack = attack

			entity_spawned.emit(explosion)

		if repeat_prop.check_empty():
			get_parent().server_remove_entity(self)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["direction"] = direction
	dict["attack"] = attack.save()
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	direction = dict["direction"]
	attack = Attack.from_saved(dict["attack"])
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
