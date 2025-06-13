class_name Bullet
extends Area2D

const _EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const SPEED = 800

@export var lives: LivesProp

var direction: float
var target_filter: TargetFilter
var effects: Array[Effect] = []

@onready var _entity_manager := get_parent() as EntityManager


func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED * delta
	global_rotation = direction


func _on_timer_timeout() -> void:
	get_parent().remove_entity(self)


func _on_body_entered(body: Node2D) -> void:
	if is_multiplayer_authority():
		if (body.has_node(^"Components/HitboxComp")
				and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
			var explosion = _EXPLOSION_SCENE.instantiate()
			explosion.global_position = global_position
			explosion.target_filter = target_filter
			explosion.effects = effects

			_entity_manager.add_entity(explosion, self)

			if lives.try_die():
				get_parent().remove_entity(self)

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
