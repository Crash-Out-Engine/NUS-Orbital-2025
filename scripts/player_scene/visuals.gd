extends Node2D

const V_MODULATE := 100000000.0
const BLEED_TIME := 2.0 / 30.0

@onready var player_sprite := $PlayerSprite as AnimatedSprite2D
@onready var player_ranged := $"../Ranged" as RangedBase
@onready var gun_sprite := $GunSprite as AnimatedSprite2D
@onready var player := get_parent() as Player


func _ready() -> void:
	player_ranged.bullet_spawned.connect(play_fire)
	player.health_changed.connect(play_bleed)


func _process(delta: float) -> void:
	# player_sprite processes
	var horizontal_dir = Input.get_axis("left", "right")
	if horizontal_dir != 0:
		player_sprite.flip_h = horizontal_dir < 0
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) != Vector2.ZERO:
		player_sprite.play("running")
	else:
		player_sprite.play("idle")
	if (player_sprite.modulate.v > 1):
		player_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (player_sprite.modulate.v <= 1):
			player_sprite.modulate.v = 1

	# gun_sprite processes
	gun_sprite.look_at(get_global_mouse_position())
	gun_sprite.flip_v = get_global_mouse_position().x < player_ranged.global_position.x
	gun_sprite.offset.y = -1 if (get_global_mouse_position().x < player_ranged.global_position.x) else 1


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("add turret"):
		gun_sprite.play("wrench")
	
	if Input.is_action_just_released("add turret"):
		gun_sprite.play("idle")


func play_fire(_bullet):
	gun_sprite.sprite_frames.set_animation_speed("fire", 4.0 / player_ranged.ranged_cooldown.value)
	gun_sprite.play("fire")


func play_bleed(_new_ratio):
	player_sprite.modulate.v = V_MODULATE
