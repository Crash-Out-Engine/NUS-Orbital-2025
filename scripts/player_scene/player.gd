class_name Player
extends CharacterBody2D

signal turret_spawned(turret: Node2D)
signal turret_placement_failed()
signal health_changed(new_ratio: float)
signal scrap_changed(new_value: int)

const _TURRET_SCENE := preload("res://scenes/turret.tscn")

enum Hand {
	HOLDING_GUN,
	FIRING_GUN,
	HOLDING_WRENCH,
	FIRING_WRENCH,
	PLANNING_WRENCH
}

const KNOCKBACK_DURATION = 0.5
const KNOCKBACK_AMOUNT = 300.0
const PICKUP_RANGE = 40

@export_group("Components")
@export var ranged: RangedBaseComp

@export_group("Properties")
@export var health: HealthProp
@export var health_capacity: HealthCapacityProp
@export var melee_cooldown: MeleeCooldownProp

var hand_action = Hand.HOLDING_GUN
var hand_locked: bool = false
var direction: Callable = func(_delta: float) -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
		)
var knockback = 0.0
var knockback_direction = Vector2(0, 0)
var current_turret = null
var scrap = 50:
	set(value):
		scrap = value
		scrap_changed.emit(value)

var turret_cost = 25

@onready var visuals := $Visuals as PlayerVisuals
@onready var melee_player := $MeleePlayer as AnimationPlayer


func _ready() -> void:
	health_changed.emit(1.0)
	ranged.active = false


func _process(delta: float) -> void:
	if knockback > 0:
		knockback -= KNOCKBACK_AMOUNT * delta / KNOCKBACK_DURATION
	elif knockback < 0:
		knockback = 0


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if hand_action == Hand.HOLDING_GUN:
			hand_action = Hand.FIRING_GUN
			ranged.active = true
	
	if Input.is_action_just_released("shoot"):
		if hand_action == Hand.FIRING_GUN:
			ranged.active = false
			hand_action = Hand.HOLDING_GUN
	
	if Input.is_action_just_pressed("melee"):
		if hand_action == Hand.HOLDING_GUN and melee_cooldown.can_melee():
			hand_action = Hand.FIRING_WRENCH
			melee_player.play("melee_attack")
			visuals.play_melee_fire()
			hand_locked = true
	
	if Input.is_action_pressed("melee"):
		if (hand_action == Hand.HOLDING_WRENCH or hand_action == Hand.HOLDING_GUN) and melee_cooldown.can_melee():
			hand_action = Hand.FIRING_WRENCH
			melee_player.play("melee_attack")
			visuals.play_melee_fire()
			hand_locked = true
	
	if Input.is_action_just_released("melee"):
		if !hand_locked and hand_action == Hand.HOLDING_WRENCH:
			hand_action = Hand.HOLDING_GUN
	
	if Input.is_action_just_pressed("add turret"):
		hand_action = Hand.PLANNING_WRENCH
		ranged.active = false
		hand_locked = false
		current_turret = _TURRET_SCENE.instantiate()
		current_turret.global_position = get_global_mouse_position()
		current_turret.player = self
		turret_spawned.emit(current_turret)
	
	if Input.is_action_pressed("add turret"):
		if current_turret != null:
			current_turret.global_position = get_global_mouse_position()
			if !can_place_turret():
				current_turret.get_node_or_null(^"Visuals").set_visual_modulate(Color(1, 0, 0, 0.5))
			else:
				current_turret.get_node_or_null(^"Visuals").set_visual_modulate(Color(0, 1, 1, 0.5))
	
	if Input.is_action_just_released("add turret"):
		if current_turret != null:
			if can_place_turret():
				current_turret.advance_state()
				scrap -= turret_cost
			else:
				current_turret.state = Turret.State.CANCELLED
				turret_placement_failed.emit()
			current_turret = null
		hand_action = Hand.HOLDING_GUN


func can_place_turret() -> bool:
	return current_turret != null and !current_turret.is_overlapping() and turret_cost <= scrap


func get_health() -> float:
	return health.value


func get_health_capacity() -> float:
	return health_capacity.value


func gain_scrap(amount: int) -> void:
	scrap += amount


func _on_health_emptied() -> void:
	get_tree().reload_current_scene()


func apply_knockback(source: Node2D) -> void:
	knockback_direction = (global_position - source.global_position).normalized()
	knockback = KNOCKBACK_AMOUNT


func _on_visuals_melee_finished() -> void:
	if Input.is_action_pressed("melee"):
		hand_action = Hand.HOLDING_WRENCH
	else:
		hand_action = Hand.HOLDING_GUN
	hand_locked = false


func _on_health_changed(_from: float, to: float) -> void:
	health_changed.emit(to / health_capacity.value)
