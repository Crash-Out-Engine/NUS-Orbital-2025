class_name Explosion
extends Area2D

@export var explosion_mod_comp: ExplosionModComp
@export var repeat_prop: RepeatProp
@export var size_prop: SizeProp

var target_filter: TargetFilter
var effects: Array[EffectBase] = []

func _ready() -> void:
	size_prop.size_changed.connect(func(value): scale = value * Vector2(1.0, 1.0))
	explosion_mod_comp._setup_mods()

func _enter_tree() -> void:
	call_deferred("explode")


func explode() -> void:
	for i in repeat_prop.value:
		$AnimatedSprite2D.play("default")
		$AudioStreamPlayer.play()

		# The node should process overlapping bodies *after* a physics frame.
		# Note that overlapping bodies are only calculated during a physics frame.
		await get_tree().physics_frame

		# the explosion should only check for and apply effects only once
		for body in get_overlapping_bodies():
			if (body.get_node_or_null(^"Components/HitboxComp") != null
					and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
				for effect in effects:
					body.get_node_or_null(^"Components/HitboxComp").trigger(effect)

		await $AnimatedSprite2D.animation_finished
	queue_free()

func assign_mods(mods: Array[ModBase]) -> void:
	explosion_mod_comp.mods.assign(mods)

func set_size(size: float):
	scale = size * Vector2(1.0, 1.0)
