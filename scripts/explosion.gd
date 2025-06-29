class_name Explosion
extends Area2D

@export var explosion_mod_comp: ExplosionModComp
@export var repeat_prop: RepeatProp
@export var size_prop: SizeProp
@export var timeout_prop: TimeoutProp

var target_filter: TargetFilter
var effects: Array[Effect] = []

@onready var anim_player = $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	explosion_mod_comp.setup_mods()

func _enter_tree() -> void:
	call_deferred("explode")


func explode() -> void:
	if not is_inside_tree():
		return

	for i in repeat_prop.value:
		anim_player.speed_scale = 0.2 / timeout_prop.value
		anim_player.play("explode")
		$AudioStreamPlayer.play()
		await anim_player.animation_finished
	get_parent().remove_entity(self)

func assign_mods(mods: Array[ModBase]) -> void:
	explosion_mod_comp.mods.assign(mods)

func _on_body_entered(body: Node2D) -> void:
	if (body.has_node(^"Components/HitboxComp")
			and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
		body.get_node(^"Components/HitboxComp").trigger(effects, self)
		body.get_node(^"Components/HitboxComp").apply_knockback(global_position)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["rotation"] = rotation
	dict["target_filter"] = target_filter.save()
	dict["effects"] = Effect.save_array(effects)
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	rotation = dict["rotation"]
	target_filter = TargetFilter.from_saved(dict["target_filter"])
	effects = Effect.from_saved_array(dict["effects"])
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
