extends CharacterBody2D

var bullet_scene = preload("res://scenes/bullet.tscn")

var direction: Callable = func(_delta: float) -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"), 
		Input.get_axis("up", "down")
		)

@onready var barrel = $Barrel
@onready var shoot_timer = $ShootTimer

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot") and shoot_timer.is_stopped():
		var bullet = bullet_scene.instantiate()
		bullet.global_position = barrel.global_position
		bullet.direction = global_position.angle_to_point(get_global_mouse_position())
		
		shoot_timer.start()
		$/root/Game.add_child(bullet)
