class_name ModTargetingComp
extends Area2D

var _current_target: Turret

func _ready() -> void:
	_current_target = null

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())

func get_target() -> Node2D:
	if _current_target == null:
		return $"../.."
	else:
		return _current_target

func _on_body_entered(body: Node2D) -> void:
	if body is Turret:
		if _current_target != null:
			_current_target.highlighted = false
		_current_target = body
		_current_target.highlighted = true

func _on_body_exited(body: Node2D) -> void:
	if body == _current_target:
		_current_target.highlighted = false
		_current_target = null
		
		var min_target: Turret
		var min_dist_squared := INF
		for new_body in get_overlapping_bodies():
			if new_body is Turret:
				if new_body.global_position.distance_squared_to(global_position) < min_dist_squared:
					min_target = new_body

		_current_target = min_target
		if _current_target != null:
			_current_target.highlighted = true
