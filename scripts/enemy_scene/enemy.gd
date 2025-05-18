class_name Enemy
extends RigidBody2D

signal vfx_emitted(Node2D)

const BLEED_TIME = 0.04
const V_MODULATE = 100000000

@export var target_provider := load("res://resources/target_provider.tres") as TargetProvider

var loot_scene = preload("res://scenes/loot.tscn")

@onready var timer: Timer = $Timer
@onready var ranged: RangedAI = $Ranged
@onready var target_priority: TargetPriority = $TargetPriority


func _ready() -> void:
	$Health.just_emptied.connect(die)


func die():
	queue_free()
	
	var loot = loot_scene.instantiate()
	loot.global_position = global_position
	vfx_emitted.emit(loot)
