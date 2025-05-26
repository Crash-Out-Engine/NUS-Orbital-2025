extends Node2D

const V_MODULATE := 100000000.0
const BLEED_TIME := 2.0 / 30.0

signal melee_finished()

@onready var player_sprite := $PlayerSprite as AnimatedSprite2D
@onready var player_ranged := $"../Ranged" as RangedBase
@onready var player_melee := $"../Melee" as Melee
@onready var gun_sprite := $GunSprite as AnimatedSprite2D
@onready var gun_blast_sprite := $GunSprite/GunBlastSprite as AnimatedSprite2D
@onready var player := get_parent() as Player
@onready var hitbox := $"../CollisionShape2D" as CollisionShape2D
@export var melee_cooldown: MeleeCooldown

var aim_locked = false

func _ready() -> void:
	player_ranged.bullet_spawned.connect(play_gun_fire)
	player.health_changed.connect(play_bleed)
	gun_sprite.play("gun_idle")
	gun_blast_sprite.visible = false
	aim_locked = false


func _process(delta: float) -> void:
	# player_sprite processes
	var horizontal_dir = Input.get_axis("left", "right")
	if horizontal_dir != 0:
		player_sprite.flip_h = horizontal_dir < 0
		player_sprite.offset.x = 1 if horizontal_dir < 0 else -1
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) != Vector2.ZERO:
		player_sprite.play("running")
	else:
		player_sprite.play("idle")
	if (player_sprite.modulate.v > 1):
		player_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (player_sprite.modulate.v <= 1):
			player_sprite.modulate.v = 1

	# gun_sprite processes
	if(!aim_locked and !player.mouse_is_in_player()):
		gun_sprite.look_at(get_global_mouse_position())
		gun_sprite.flip_v = get_global_mouse_position().x < player_ranged.global_position.x
		gun_sprite.offset.y = -1 if (get_global_mouse_position().x < player_ranged.global_position.x) else 1


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("add turret"):
		gun_sprite.play("melee_idle")
	
	if Input.is_action_just_released("add turret"):
		gun_sprite.play("gun_idle")
	


func play_gun_fire(_bullet):
	gun_sprite.sprite_frames.set_animation_speed("gun_fire", 4.0 / player_ranged.ranged_cooldown.value)
	gun_sprite.play("gun_fire")
	gun_blast_sprite.visible = true
	gun_blast_sprite.play("default")

func play_melee_fire():
	player_melee.look_at(get_global_mouse_position())
	gun_sprite.offset.x = 28.5
	gun_sprite.play("melee_fire")
	aim_locked = true

func play_bleed(_new_ratio):
	player_sprite.modulate.v = V_MODULATE


func _on_gun_sprite_animation_finished() -> void:
	if(gun_sprite.animation == "melee_fire"):
		gun_sprite.offset.x = 14.5
		gun_sprite.play("gun_idle")
		melee_finished.emit()
		aim_locked = false


func _on_gun_blast_sprite_animation_finished() -> void:
	gun_blast_sprite.visible = false
