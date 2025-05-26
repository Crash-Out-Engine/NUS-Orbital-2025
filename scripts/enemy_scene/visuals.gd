extends Node2D

const BLEED_TIME = 0.04
const V_MODULATE = 100000000

@export var target_provider := load("res://resources/target_provider.tres") as TargetProvider

@onready var enemy_health := $"../Health" as Health
@onready var target_priority := $"../TargetPriority" as TargetPriority
@onready var body_sprite := $BodySprite as AnimatedSprite2D
@onready var flames_sprite := $FlamesSprite as AnimatedSprite2D
@onready var legs_sprite := $LegsSprite as AnimatedSprite2D

signal bleeded()


func _ready() -> void:
	enemy_health.just_emptied.connect(play_die_effect)
	enemy_health.just_reduced.connect(func(_bleed): play_bleed_effect())
	flames_sprite.play("default")
	legs_sprite.play("default")


func _process(delta: float) -> void:
	# bleeding effect
	if (body_sprite.modulate.v > 1):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1):
			body_sprite.modulate.v = 1
		if(body_sprite.modulate.v == 1):
			bleeded.emit()

	# sprite direction
	var target = target_provider.get_target(global_position, target_priority.team)
	if target != null:
		var flip_h = target.global_position.x < global_position.x
		body_sprite.flip_h = flip_h
		flames_sprite.flip_h = flip_h
		legs_sprite.flip_h = flip_h


func play_die_effect():
	body_sprite.modulate.v = V_MODULATE


func play_bleed_effect():
	body_sprite.modulate.v = V_MODULATE
