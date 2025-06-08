class_name PlayerVisuals
extends Node2D

signal melee_finished()

const V_MODULATE := 100000000.0
const BLEED_TIME := 2.0 / 30.0

@export var player_ranged: RangedBaseComp
@export var player_melee: MeleeComp
@export var player_repair: MeleeComp
@export var player: Player

@onready var player_sprite := $PlayerSprite as AnimatedSprite2D
@onready var gun_sprite := $GunSprite as AnimatedSprite2D
@onready var gun_blast_sprite := $GunSprite/GunBlastSprite as AnimatedSprite2D


func _ready() -> void:
	player_ranged.bullet_spawned.connect(play_gun_fire)
	player.health_changed.connect(play_bleed)
	player.no_lives.connect(play_death)
	gun_sprite.play("gun_idle")


func _process(delta: float) -> void:
	if (player_sprite.modulate.v > 1):
		player_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (player_sprite.modulate.v <= 1):
			player_sprite.modulate.v = 1

	if not player.can_control: 
		if !player.hand_locked:
			gun_sprite.look_at(get_global_mouse_position())
			gun_sprite.scale.y = -1 if get_global_mouse_position().x < player_ranged.global_position.x else 1
		return
	# player_sprite processes
	var horizontal_dir = Input.get_axis("left", "right")
	if horizontal_dir != 0:
		player_sprite.flip_h = horizontal_dir < 0
	if Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) != Vector2.ZERO:
		player_sprite.play("running")
	else:
		player_sprite.play("idle")
	

	# gun_sprite processes
	if !player.hand_locked:
		gun_sprite.look_at(get_global_mouse_position())
		gun_sprite.scale.y = -1 if get_global_mouse_position().x < player_ranged.global_position.x else 1


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("melee"):
		if (!player.hand_locked
				and gun_sprite.animation == "melee_idle"
				and !Input.is_action_pressed("add turret")):
			gun_sprite.play("gun_idle")

	if Input.is_action_just_pressed("add turret"):
		gun_sprite.play("melee_idle")

	if Input.is_action_just_released("add turret"):
		gun_sprite.play("gun_idle")

	if Input.is_action_just_pressed("inventory"):
		if player_sprite.animation == "running":
			player_sprite.play("idle")
		if player.opening_inventory:
			gun_sprite.play("melee_idle")

func reset():
	player_sprite.play("idle")
	gun_sprite.play("gun_idle")

func play_gun_fire(_bullet):
	gun_sprite.sprite_frames.set_animation_speed("gun_fire", 4.0 / player_ranged.ranged_cooldown.value)
	gun_sprite.play("gun_fire")
	gun_blast_sprite.play()


func play_melee_fire():
	player_melee.rotation = gun_sprite.rotation
	player_repair.rotation = gun_sprite.rotation
	gun_sprite.play("melee_fire")

func play_bleed():
	player_sprite.modulate.v = V_MODULATE

func _on_gun_sprite_animation_finished() -> void:
	if gun_sprite.animation == "melee_fire":
		if Input.is_action_pressed("melee"):
			gun_sprite.play("melee_idle")
		else:
			gun_sprite.play("gun_idle")
		melee_finished.emit()

func play_death():
	player_sprite.modulate.v = 1
	player_sprite.play("death")
	gun_sprite.visible = false

func deactivate():
	gun_sprite.visible = false
	if player_sprite.animation != "death":
		player_sprite.play("lost")
