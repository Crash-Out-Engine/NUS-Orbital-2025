class_name Player extends CharacterBody2D

var turret_scene = preload("res://scenes/turret.tscn")

const GUN_ITEM = 0
const WRENCH_ITEM = 1
const V_MODULATE = 100000000
const BLEED_TIME = 2.0/30.0
var held_item = GUN_ITEM

var direction: Callable = func(_delta: float) -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
		)

var knockback = 0.0
var knockback_direction = Vector2(0, 0)
const KNOCKBACK_DURATION = 0.5
const KNOCKBACK_AMOUNT = 800.0

@onready var anim = $PlayerSprite
@onready var ranged = $Ranged
@onready var footstep_sounds = $FootstepsPlayer

signal turret_spawned(turret: Node2D)

var current_turret = null

const PICKUP_RANGE = 125

func _ready() -> void:
	health_changed.emit(1.0)
	ranged.active = false
	$Health.just_reduced.connect(bleed)
	
func _process(delta: float) -> void:
	var horizontal_dir = Input.get_axis("left", "right")
	if horizontal_dir != 0:
		anim.flip_h = horizontal_dir < 0
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")):
		anim.play("running")
		if(!footstep_sounds.playing):
			footstep_sounds.play()
	else:
		anim.play("idle")
		footstep_sounds.stop()
	if knockback > 0:
		knockback -= KNOCKBACK_AMOUNT * delta/KNOCKBACK_DURATION
	elif knockback < 0:
		knockback = 0
	if(anim.modulate.v > 1):
		anim.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if(anim.modulate.v <= 1):
			anim.modulate.v = 1

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		if(held_item == GUN_ITEM):
			ranged.active = true
	
	if Input.is_action_just_released("shoot"):
		ranged.active = false
	
	if Input.is_action_just_pressed("add turret"):
		held_item = WRENCH_ITEM
		$Ranged/GunSprite.play("wrench")
		current_turret = turret_scene.instantiate()
		current_turret.set_collidable(false)
		current_turret.set_visual_modulate(0, 1, 1, 0.5)
		current_turret.global_position = get_global_mouse_position()
		turret_spawned.emit(current_turret)
	
	if Input.is_action_pressed("add turret"):
		if current_turret != null:
			current_turret.global_position = get_global_mouse_position()
			if(current_turret.is_overlapping()):
				current_turret.set_visual_modulate(1, 0, 0, 0.5)
			else:
				current_turret.set_visual_modulate(0, 1, 1, 0.5)


	if Input.is_action_just_released("add turret"):
		if current_turret != null:
			if(!current_turret.is_overlapping()):
				current_turret.build()
			else:
				current_turret.queue_free()
			current_turret = null
		held_item = GUN_ITEM
		$Ranged/GunSprite.play("idle")

		

func _on_health_just_emptied() -> void:
	print("died")
	get_tree().reload_current_scene()

signal health_changed(new_ratio: float)

func _on_health_just_changed(_old_value: float, new_value: float) -> void:
	health_changed.emit(new_value / $Health.health_capacity)

func get_health() -> int:
	return $Health.value

func get_knockedback(source: Node2D) -> void:
	knockback_direction = (global_position - source.global_position).normalized()
	knockback = KNOCKBACK_AMOUNT
	
func bleed(_amount: float):
	anim.modulate.v = V_MODULATE
