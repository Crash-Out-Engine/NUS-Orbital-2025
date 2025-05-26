extends Node2D

const BLEED_TIME = 0.04
const V_MODULATE = 100000000

@export var health_prop: HealthProp
@export var target_priority_prop: TargetPriorityProp

@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider
@onready var body_sprite := $BodySprite as AnimatedSprite2D
@onready var flames_sprite := $FlamesSprite as AnimatedSprite2D
@onready var legs_sprite := $LegsSprite as AnimatedSprite2D


func _ready() -> void:
	health_prop.just_emptied.connect(play_die_effect)
	health_prop.just_reduced.connect(func(_bleed): play_bleed_effect())
	flames_sprite.play("default")
	legs_sprite.play("default")


func _process(delta: float) -> void:
	# bleeding effect
	if (body_sprite.modulate.v > 1):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1):
			body_sprite.modulate.v = 1

	# sprite direction
	var target = target_provider.get_target(global_position, target_priority_prop.team)
	if target != null:
		var flip_h = target.global_position.x < global_position.x
		body_sprite.flip_h = flip_h
		flames_sprite.flip_h = flip_h
		legs_sprite.flip_h = flip_h


func play_die_effect():
	body_sprite.modulate.v = V_MODULATE


func play_bleed_effect():
	body_sprite.modulate.v = V_MODULATE
