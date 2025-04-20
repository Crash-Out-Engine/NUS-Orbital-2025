class_name Player extends CharacterBody2D

var turret_scene = preload("res://scenes/turret.tscn")

var direction: Callable = func(_delta: float) -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
		)

@onready var barrel = $Barrel
@onready var ranged = $Ranged

signal turret_spawned(turret: Node2D)

var current_turret = null

func _ready() -> void:
	health_changed.emit(1.0)
	ranged.effects.append_array([
		MovementEffect.create_freeze(1.0),
		HealthEffect.create_lasting(6, 4, 1),
		HealthEffect.create_instant(3.0),
	])

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		ranged.active = true
	if Input.is_action_just_released("shoot"):
		ranged.active = false
		
	if Input.is_action_just_pressed("add turret"):
		current_turret = turret_scene.instantiate()
		current_turret.set_collidable(false)
		current_turret.global_position = get_global_mouse_position()
		turret_spawned.emit(current_turret)
	
	if Input.is_action_pressed("add turret"):
		if current_turret != null:
			current_turret.global_position = get_global_mouse_position()

	if Input.is_action_just_released("add turret"):
		if current_turret != null:
			current_turret.set_collidable(true)
			current_turret = null
		

func _on_health_just_emptied() -> void:
	print("died")
	get_tree().reload_current_scene()
	
signal health_changed(new_ratio: float)
func _on_health_just_changed(_old_value: float, new_value: float) -> void:
	health_changed.emit(new_value / $Health.health_capacity)
