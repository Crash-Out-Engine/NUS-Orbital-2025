extends Node2D

const V_MODULATE := 100000000.0
const BLEED_TIME := 2.0 / 30.0

signal melee_finished()

@export var player_ranged: RangedBaseComp
@export var player_melee: MeleeComp
@export var player: Player

@onready var player_sprite := $PlayerSprite as AnimatedSprite2D
@onready var gun_sprite := $GunSprite as AnimatedSprite2D


func _ready() -> void:
	player_ranged.bullet_spawned.connect(play_gun_fire)
	player.health_changed.connect(play_bleed)
	gun_sprite.play("gun_idle")


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
		gun_sprite.play("melee_idle")
	
	if Input.is_action_just_released("add turret"):
		gun_sprite.play("gun_idle")
	
	if Input.is_action_just_pressed("melee"):
		play_melee_fire()


func play_gun_fire(_bullet):
	gun_sprite.sprite_frames.set_animation_speed("gun_fire", 4.0 / player_ranged.ranged_cooldown.value)
	gun_sprite.play("gun_fire")

func play_melee_fire():
	player_melee.look_at(get_global_mouse_position())
	gun_sprite.sprite_frames.set_animation_speed("melee_fire", 8.0 / (2 * player_melee.melee_cooldown.value))
	gun_sprite.play("melee_fire")

func play_bleed(_new_ratio):
	player_sprite.modulate.v = V_MODULATE


func _on_gun_sprite_frame_changed() -> void:
	if (gun_sprite.animation == "melee_fire"):
		if (gun_sprite.frame == 2):
			player_melee.monitoring = true
		elif (gun_sprite.frame == 7):
			player_melee.monitoring = false


func _on_gun_sprite_animation_finished() -> void:
	if (gun_sprite.animation == "melee_fire"):
		gun_sprite.play("gun_idle")
		melee_finished.emit()
