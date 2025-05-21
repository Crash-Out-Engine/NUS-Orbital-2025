class_name Player
extends CharacterBody2D

signal turret_spawned(turret: Node2D)
signal turret_placement_failed()
signal health_changed(new_ratio: float)
signal scrap_changed()

const _TURRET_SCENE := preload("res://scenes/turret.tscn")

enum Hand {
	HOLDING_GUN,
	FIRING_GUN,
	HOLDING_WRENCH,
	FIRING_WRENCH
}

const KNOCKBACK_DURATION = 0.5
const KNOCKBACK_AMOUNT = 800.0
const PICKUP_RANGE = 125

var hand_action = Hand.HOLDING_GUN
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


func _ready() -> void:
	health_changed.emit(1.0)
	ranged.active = false


func _process(delta: float) -> void:
	if knockback > 0:
		knockback -= KNOCKBACK_AMOUNT * delta / KNOCKBACK_DURATION
	elif knockback < 0:
		knockback = 0


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		if (hand_action == Hand.HOLDING_GUN):
			hand_action = Hand.FIRING_GUN
			ranged.active = true
	
	if Input.is_action_just_released("shoot"):
		ranged.active = false
		hand_action = Hand.HOLDING_GUN
	
	if Input.is_action_just_pressed("melee"):
		if(hand_action == Hand.HOLDING_GUN):
			hand_action = Hand.FIRING_WRENCH
		
	
	if Input.is_action_just_pressed("add turret"):
		hand_action = Hand.HOLDING_WRENCH
		current_turret = _TURRET_SCENE.instantiate()
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
			if can_place_turret():
				current_turret.advance_state() # TODO: implement other turret states properly
				current_turret.advance_state()
				current_turret.advance_state()
				scrap -= turret_cost
				turrets_placed += 1
				turret_cost = (turrets_placed + 1) * turrets_placed * 5 / 2
				scrap_changed.emit()
			else:
				current_turret.state = Turret.State.CANCELLED
				turret_placement_failed.emit()
			current_turret = null
		hand_action = Hand.HOLDING_GUN


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

func _on_visuals_melee_finished() -> void:
	hand_action = Hand.HOLDING_GUN
