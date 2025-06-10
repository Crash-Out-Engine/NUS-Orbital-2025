class_name EnemyVisuals
extends Node2D

signal bleed_finished()

const BLEED_TIME = 0.04
const V_MODULATE = 100000000
const FLIP_THRESHOLD: float = 0.001

@export var enemy: Enemy
@export var health: HealthProp

@onready var body_sprite := $BodySprite as AnimatedSprite2D
@onready var flames_sprite := $FlamesSprite as AnimatedSprite2D
@onready var legs_sprite := $LegsSprite as AnimatedSprite2D


func _ready() -> void:
	health.emptied.connect(play_die_effect)
	health.reduced.connect(func(_bleed): play_bleed_effect())
	flames_sprite.play("default")
	legs_sprite.play("default")


func _process(delta: float) -> void:
	# bleeding effect
	if (body_sprite.modulate.v > 1):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1):
			body_sprite.modulate.v = 1
			bleed_finished.emit()

	# sprite direction
	var x_velocity = enemy.linear_velocity.x
	if absf(x_velocity) > FLIP_THRESHOLD:
		var flip_h = x_velocity < 0
		body_sprite.flip_h = flip_h
		flames_sprite.flip_h = flip_h
		legs_sprite.flip_h = flip_h


func play_die_effect():
	body_sprite.modulate.v = V_MODULATE


func play_bleed_effect():
	body_sprite.modulate.v = V_MODULATE
