class_name ModTargetingComp
extends Area2D

var current_target: Turret

func _ready() -> void:
	current_target = null

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())

func _on_body_entered(body: Node2D) -> void:
	if body is Turret:
		if current_target != null:
			current_target.highlighted = false
		current_target = body
		current_target.highlighted = true

func _on_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target.highlighted = false
		current_target = null
		for i in get_overlapping_bodies():
			if i is Turret:
				current_target = i
				i.highlighted = true
