class_name Bullet
extends Area2D

const _EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const SPEED = 800

@export_group("Components")
@export var bullet_mods_comp: BulletModsComp

@export_group("Properties")
@export var repeat_prop: RepeatProp
@export var size_prop: SizeProp
@export var copy_prop: CopyProp
@export var spread_prop: SpreadProp
@export var timeout_prop: TimeoutProp

var direction: float
var target_filter: TargetFilter
var effects: Array[EffectBase] = []

@onready var timer = $Timer as Timer

func _ready() -> void:
	size_prop.size_changed.connect(set_size)
	timeout_prop.changed.connect(func(_from, to): timer.wait_time = to)
	bullet_mods_comp._setup_mods()
	timer.start()

func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED * delta
	global_rotation = direction


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if (body.get_node_or_null(^"Components/HitboxComp") != null
			and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
		var pos_offset = (copy_prop.value - 1) * spread_prop.value * Vector2(1.0, 1.0) as Vector2
		var interval = 2 * PI / copy_prop.value
		for i in copy_prop.value:
			var explosion = _EXPLOSION_SCENE.instantiate()
			explosion.global_position = global_position + pos_offset.rotated(i * interval)
			explosion.target_filter = target_filter
			explosion.assign_mods(bullet_mods_comp.mods)
			explosion.effects = effects
			call_deferred("add_sibling", explosion)

		if repeat_prop.check_empty():
			queue_free()

func assign_mods(mods: Array[ModBase]) -> void:
	bullet_mods_comp.mods.assign(mods)

func set_size(size: float):
	scale = size * Vector2(1.0, 1.0)
