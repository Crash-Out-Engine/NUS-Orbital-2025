class_name Player
extends CharacterBody2D

signal turret_spawned(turret: Node2D)
signal turret_placement_failed()

signal health_changed()
signal scraps_changed()
signal no_lives()

enum Hand {
	HOLDING_GUN,
	FIRING_GUN,
	HOLDING_WRENCH,
	FIRING_WRENCH,
	PLANNING_WRENCH
}

const _TURRET_SCENE := preload("res://scenes/turret.tscn")

@export_group("Components")
@export var ranged: RangedBaseComp
@export var inventory: InventoryComp
@export var blueprints: BlueprintComp
@export var mod_target: ModTargetingComp
@export var mod_slots: ModSlotComp

@export_group("Properties")
@export var health_prop: HealthProp
@export var health_capacity: HealthCapacityProp
@export var melee_cooldown: MeleeCooldownProp
@export var size_prop: SizeProp
@export var lives: RepeatProp

var can_control = true
var hand_action = Hand.HOLDING_GUN
var hand_locked: bool = false
var direction: Callable = func(_delta: float) -> Vector2:
	if !can_control: return Vector2(0, 0)
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
		)
var current_turret = null
var turret_cost = 25
var inventory_target: Turret
var opening_inventory = false
var size = 1.0

@onready var visuals := $Visuals as PlayerVisuals
@onready var audio := $Audio as PlayerAudio
@onready var melee_player := $MeleePlayer as AnimationPlayer


func _ready() -> void:
	inventory.scraps_changed.connect(func(_from: int, _to: int): scraps_changed.emit())
	health_prop.changed.connect(func(_from: int, _to: int): health_changed.emit())
	size_prop.size_changed.connect(change_size)
	health_changed.emit()
	ranged.active = false


func _process(_delta: float) -> void:
	if scale.x != size:
		var i = 1 if size > scale.x else -1
		scale += i * SizeProp.GROWTH_SPEED * Vector2(1.0, 1.0)
		if size > scale.x != (i == 1):
			scale = size * Vector2(1.0, 1.0)


func _physics_process(_delta: float) -> void:
	if not can_control: return

	if Input.is_action_pressed("shoot"):
		if hand_action == Hand.HOLDING_GUN:
			hand_action = Hand.FIRING_GUN
			ranged.active = true

	if Input.is_action_just_released("shoot"):
		if hand_action == Hand.FIRING_GUN:
			ranged.active = false
			hand_action = Hand.HOLDING_GUN

	if Input.is_action_pressed("melee"):
		if hand_action in [Hand.HOLDING_GUN, Hand.HOLDING_WRENCH] and melee_cooldown.can_melee():
			hand_action = Hand.FIRING_WRENCH
			melee_player.speed_scale = 0.5 / melee_cooldown.value
			melee_player.play("melee_attack")
			visuals.play_melee_fire()
			audio.play_melee_swing_sound()
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
		current_turret.player = self # TODO: Decouple player in multiplayer implementation
		turret_spawned.emit(current_turret)

	if Input.is_action_pressed("add turret"):
		if current_turret != null:
			current_turret.global_position = get_global_mouse_position()
			if !_can_place_turret():
				current_turret.get_node_or_null(^"Visuals").set_visual_modulate(Color(1, 0, 0, 0.5))
			else:
				current_turret.get_node_or_null(^"Visuals").set_visual_modulate(Color(0, 1, 1, 0.5))

	if Input.is_action_just_released("add turret"):
		if current_turret != null:
			if _can_place_turret():
				current_turret.advance_state()
				inventory.use_scraps(turret_cost)
			else:
				current_turret.state = Turret.State.CANCELLED
				turret_placement_failed.emit()
			current_turret = null
		hand_action = Hand.HOLDING_GUN

func get_inventory() -> InventoryComp:
	return inventory

func get_mod_slots() -> ModSlotComp:
	if mod_target.current_target == null:
		return mod_slots
	return mod_target.current_target.get_mod_slots()

func open_inventory():
	can_control = false
	hand_action = Hand.HOLDING_WRENCH
	ranged.active = false
	visuals.play_inventory()

func close_inventory():
	can_control = true
	hand_action = Hand.HOLDING_GUN
	visuals.reset()

# HACK: Temporary for testing, @deltaMinor please remove
func add_random_mod(turret: Turret) -> void:
	if (turret.get_node_or_null(^"Components/ModSlotComp") != null
			and turret.get_node(^"Components/ModSlotComp").get_mods().find(null) == -1):
		assert(false, "WOT?")
	var inventory_mods = inventory.get_mods()
	for key: ModBase in inventory_mods.keys():
		if inventory_mods[key] > 0:
			inventory.access_entity(turret)
			inventory._handle_mod_equipped(key)
			inventory.unaccess_entity()
			return


# region forwarding


func get_health() -> float:
	return health_prop.value


func get_health_capacity() -> float:
	return health_capacity.value


func get_scraps() -> int:
	return inventory.get_scraps()


func use_scraps(amount: int) -> void:
	inventory.use_scraps(amount)


# endregion


func _on_health_emptied() -> void:
	if lives.check_empty():
		can_control = false
		$CollisionShape2D.disabled = true
		ranged.active = false
		$Properties/MovementProp.active = false
		$Components/HitboxComp.team = 0
		no_lives.emit()
	else:
		respawn()

func respawn() -> void:
	health_prop.value = 10 #HACK: create proper respawn sequence


func _can_place_turret() -> bool:
	return (current_turret != null
			and !current_turret.is_overlapping()
			and turret_cost <= inventory.get_scraps())


func _on_visuals_melee_finished() -> void:
	if Input.is_action_pressed("melee"):
		hand_action = Hand.HOLDING_WRENCH
	else:
		hand_action = Hand.HOLDING_GUN
	hand_locked = false

func deactivate():
	can_control = false
	$CollisionShape2D.disabled = true
	$Properties/MovementProp.active = false
	ranged.active = false
	$Components/HitboxComp.team = 0
	visuals.deactivate()

func get_blueprints() -> Array[ModBase]:
	return blueprints.get_blueprints()

func change_size(value: float):
	size = value
