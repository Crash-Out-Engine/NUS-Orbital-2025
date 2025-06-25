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
	explosion_mod_comp._setup_mods()

func _enter_tree() -> void:
	call_deferred("explode")


func explode() -> void:
	for i in repeat_prop.value:
		anim_player.speed_scale = 0.2 / timeout_prop.value
		anim_player.play("explode")
		$AudioStreamPlayer.play()
		await anim_player.animation_finished
	queue_free()

func assign_mods(mods: Array[ModBase]) -> void:
	explosion_mod_comp.mods.assign(mods)

func set_size(size: float):
	scale = size * Vector2(1.0, 1.0)


func _on_body_entered(body: Node2D) -> void:
	if (body.get_node_or_null(^"Components/HitboxComp") != null
			and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
		body.get_node_or_null(^"Components/HitboxComp").trigger(effects, self)
