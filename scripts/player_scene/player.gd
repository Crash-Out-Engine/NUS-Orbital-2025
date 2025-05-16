class_name Player
extends CharacterBody2D

signal turret_spawned(turret: Node2D)
signal health_changed(new_ratio: float)
signal scrap_changed()

const _TURRET_SCENE := preload("res://scenes/turret.tscn")
const GUN_ITEM := 0
const WRENCH_ITEM := 1
const V_MODULATE := 100000000
const BLEED_TIME := 2.0 / 30.0
const KNOCKBACK_DURATION = 0.5
const KNOCKBACK_AMOUNT = 800.0
const PICKUP_RANGE = 125

var held_item = GUN_ITEM
var direction: Callable = func(_delta: float) -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
		)
var knockback = 0.0
var knockback_direction = Vector2(0, 0)
var current_turret = null
var scrap = 50
var turrets_placed = 0 # HACK: temporary for lift-off demonstration
var turret_cost = 5 # HACK: temporary for lift-off demonstration

@onready var ranged := $Ranged as RangedBase
@onready var footstep_sounds = $FootstepsPlayer


func _ready() -> void:
	health_changed.emit(1.0)
	ranged.active = false


func _process(delta: float) -> void:
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")):
		if (!footstep_sounds.playing):
			footstep_sounds.play()
	else:
		footstep_sounds.stop()
	if knockback > 0:
		knockback -= KNOCKBACK_AMOUNT * delta / KNOCKBACK_DURATION
	elif knockback < 0:
		knockback = 0


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		if (held_item == GUN_ITEM):
			ranged.active = true
	
	if Input.is_action_just_released("shoot"):
		ranged.active = false
	
	if Input.is_action_just_pressed("add turret"):
		held_item = WRENCH_ITEM
		current_turret = _TURRET_SCENE.instantiate()
		current_turret.set_collidable(false)
		current_turret.set_visual_modulate(Color(0, 1, 1, 0.5))
		current_turret.global_position = get_global_mouse_position()
		current_turret.player = self
		turret_spawned.emit(current_turret)
	
	if Input.is_action_pressed("add turret"):
		if current_turret != null:
			current_turret.global_position = get_global_mouse_position()
			if !can_place_turret():
				current_turret.set_visual_modulate(Color(1, 0, 0, 0.5))
			else:
				current_turret.set_visual_modulate(Color(0, 1, 1, 0.5))
	
	if Input.is_action_just_released("add turret"):
		if current_turret != null:
			if (can_place_turret()):
				current_turret.build()
				scrap -= turret_cost
				turrets_placed += 1
				turret_cost = (turrets_placed + 1) * turrets_placed * 5 / 2
				scrap_changed.emit()
			else:
				$ErrorSound.play()
				current_turret.queue_free()
			current_turret = null
		held_item = GUN_ITEM


func can_place_turret() -> bool:
	return current_turret != null and !current_turret.is_overlapping() and turret_cost <= scrap


func get_health() -> int:
	return $Health.value


func gain_scrap(amount: int) -> void:
	scrap += amount
	scrap_changed.emit()


func _on_health_just_emptied() -> void:
	get_tree().reload_current_scene()


func _on_health_just_changed(_old_value: float, new_value: float) -> void:
	health_changed.emit(new_value / $Health.health_capacity)


func apply_knockback(source: Node2D) -> void:
	knockback_direction = (global_position - source.global_position).normalized()
	knockback = KNOCKBACK_AMOUNT
