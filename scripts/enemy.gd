extends RigidBody2D

#var explosion_scene = preload("res://scenes/explosion.tscn")
var loot_scene = preload("res://scenes/loot.tscn")
@onready var timer: Timer = $Timer
@onready var ranged: RangedAI = $Ranged
@onready var target_priority: TargetPriority = $TargetPriority

@export var target_provider := load("res://resources/target_provider.tres") as TargetProvider

signal vfx_emitted(Node2D)

const BLEED_TIME = 0.125
const V_MODULATE = 100000000

func _ready() -> void:
	$Health.just_emptied.connect(die)
	$Health.just_reduced.connect(bleed)
	$BodySprite/FlamesSprite.play("default")
	$BodySprite/LegsSprite.play("default")

func _physics_process(_delta: float) -> void:
	var target = null
	target = target_provider.get_target(global_position, target_priority.team)
	if target != null:
		$BodySprite.scale.x = 2 if target.global_position.x > global_position.x else -2

func die():
	$BodySprite.modulate.v = V_MODULATE
	queue_free()
	
	#var explosion = explosion_scene.instantiate()
	#explosion.global_position = global_position
	#explosion.emitting = true
	#explosion.lifetime = randf_range(0.5, 0.7)
	#vfx_emitted.emit(explosion)
	
	var loot = loot_scene.instantiate()
	loot.global_position = global_position
	vfx_emitted.emit(loot)

func _process(delta: float) -> void:
	if($BodySprite.modulate.v > 1):
		$BodySprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if($BodySprite.modulate.v <= 1):
			$BodySprite.modulate.v = 1

func bleed(_amount: float):
	$BodySprite.modulate.v = V_MODULATE
	#var explosion = explosion_scene.instantiate()
	#explosion.global_position = global_position
	#explosion.emitting = true
	#explosion.lifetime = 0.1 + randf_range(0.2, 0.5) * (amount / $Health.health_capacity)
	#vfx_emitted.emit(explosion)
