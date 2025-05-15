extends RigidBody2D

signal vfx_emitted(Node2D)

const BLEED_TIME = 0.04
const V_MODULATE = 100000000

@export var target_provider := load("res://resources/target_provider.tres") as TargetProvider

var loot_scene = preload("res://scenes/loot.tscn")

@onready var timer: Timer = $Timer
@onready var ranged: RangedAI = $Ranged
@onready var target_priority: TargetPriority = $TargetPriority
@onready var body_sprite: AnimatedSprite2D = $BodySprite


func _ready() -> void:
	$Health.just_emptied.connect(die)
	$Health.just_reduced.connect(bleed)
	$BodySprite/FlamesSprite.play("default")
	$BodySprite/LegsSprite.play("default")


func _process(delta: float) -> void:
	if (body_sprite.modulate.v > 1):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1):
			body_sprite.modulate.v = 1


func _physics_process(_delta: float) -> void:
	var target = null
	target = target_provider.get_target(global_position, target_priority.team)
	if target != null:
		$BodySprite.scale.x = 2 if target.global_position.x > global_position.x else -2


func die():
	$BodySprite.modulate.v = V_MODULATE
	queue_free()
	
	var loot = loot_scene.instantiate()
	loot.global_position = global_position
	vfx_emitted.emit(loot)


func bleed(_amount: float):
	body_sprite.modulate.v = V_MODULATE
