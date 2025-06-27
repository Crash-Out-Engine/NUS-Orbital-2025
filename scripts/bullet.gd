class_name Bullet
extends Area2D

signal entity_spawned(entity: Node2D)

const _EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const SPEED = 800

@export_group("Properties")
@export var repeat_prop: RepeatProp
@export var size_prop: SizeProp
@export var copy_prop: CopyProp
@export var spread_prop: SpreadProp
@export var timeout_prop: TimeoutProp

@export_group("Components")
@export var bullet_mods_comp: BulletModsComp

var direction: float
var target_filter: TargetFilter
var effects: Array[Effect] = []

@onready var timer = $Timer as Timer

func _ready() -> void:
	timeout_prop.changed.connect(func(_from, to): timer.wait_time = to)
	bullet_mods_comp.setup_mods()
	timer.start()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	global_position += Vector2.from_angle(direction) * SPEED * delta
	global_rotation = direction


func _on_timer_timeout() -> void:
	get_parent().remove_entity(self)


func _on_body_entered(body: Node2D) -> void:
	if not is_multiplayer_authority():
		return

	if (body.has_node(^"Components/HitboxComp")
			and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
		var pos_offset = (copy_prop.value - 1) * spread_prop.value * Vector2(1.0, 1.0) as Vector2
		var interval = 2 * PI / copy_prop.value
		for i in copy_prop.value:
			var explosion = _EXPLOSION_SCENE.instantiate()
			explosion.global_position = global_position + pos_offset.rotated(i * interval)
			explosion.target_filter = target_filter
			explosion.assign_mods(bullet_mods_comp.mods)
			explosion.effects = effects
			
			entity_spawned.emit(explosion)

		if repeat_prop.check_empty():
			get_parent().remove_entity(self)

func assign_mods(mods: Array[ModBase]) -> void:
	bullet_mods_comp.mods.assign(mods)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["direction"] = direction
	dict["target_filter"] = target_filter.save()
	dict["effects"] = Effect.save_array(effects)
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	direction = dict["direction"]
	target_filter = TargetFilter.from_saved(dict["target_filter"])
	effects = Effect.from_saved_array(dict["effects"])
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
