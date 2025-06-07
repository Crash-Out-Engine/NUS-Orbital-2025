class_name Player
extends CharacterBody2D

signal turret_spawned(turret: Node2D)
signal turret_placement_failed()

signal health_changed()
signal scraps_changed()
signal no_lives()

signal open_inventory(inventory_comp: InventoryComp, mod_slot_comp: ModSlotComp)

enum Hand {
	HOLDING_GUN,
	FIRING_GUN,
	HOLDING_WRENCH,
	FIRING_WRENCH,
	PLANNING_WRENCH
}

const _TURRET_SCENE := preload("res://scenes/turret.tscn")
const KNOCKBACK_DURATION = 0.5
const KNOCKBACK_AMOUNT = 300.0

@export_group("Components")
@export var ranged: RangedBaseComp
@export var inventory: InventoryComp
@export var mod_target: ModTargetingComp
@export var mod_slots: ModSlotComp

@export_group("Properties")
@export var damage_taken: DamageTakenProp
@export var health_capacity: HealthCapacityProp
@export var melee_cooldown: MeleeCooldownProp

var can_control = true
var opening_inventory = false
var hand_action = Hand.HOLDING_GUN
var hand_locked: bool = false
var direction: Callable = func(_delta: float) -> Vector2:
	if !can_control: return Vector2(0, 0)
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
		)
var knockback = 0.0
var knockback_direction = Vector2(0, 0)
var current_turret = null
var turret_cost = 25
var inventory_target: Turret

@onready var visuals := $Visuals as PlayerVisuals
@onready var audio := $Audio as PlayerAudio
@onready var melee_player := $MeleePlayer as AnimationPlayer


func _ready() -> void:
	inventory.scraps_changed.connect(func(_from: int, _to: int): scraps_changed.emit())
	health_changed.emit()
	ranged.active = false


func _process(delta: float) -> void:
	if knockback > 0:
		knockback -= KNOCKBACK_AMOUNT * delta / KNOCKBACK_DURATION
	elif knockback < 0:
		knockback = 0


func _physics_process(_delta: float) -> void:
	if not can_control: 
		if opening_inventory:
			if Input.is_action_just_pressed("inventory") or Input.is_action_just_pressed("esc"):
				opening_inventory = false
				can_control = true
		return

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
				add_random_mod(current_turret)
				add_random_mod(current_turret)
			else:
				current_turret.state = Turret.State.CANCELLED
				turret_placement_failed.emit()
			current_turret = null
		hand_action = Hand.HOLDING_GUN
	
	if Input.is_action_just_pressed("inventory"):
		if mod_target.current_target == null:
			open_inventory.emit(inventory, mod_slots)
		else:
			open_inventory.emit(inventory, mod_target.current_target.get_mod_slots())
		opening_inventory = true
		can_control = false

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
	return health_capacity.value - damage_taken.value


func get_health_capacity() -> float:
	return health_capacity.value


func get_scraps() -> int:
	return inventory.get_scraps()


func use_scraps(amount: int) -> void:
	inventory.use_scraps(amount)


# endregion


func _on_health_emptied() -> void:
	can_control = false
	opening_inventory = false
	$CollisionShape2D.disabled = true
	$Components/HitboxComp.team = 0
	no_lives.emit()


func apply_knockback(source: Node2D) -> void:
	knockback_direction = (global_position - source.global_position).normalized()
	knockback = KNOCKBACK_AMOUNT


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
	opening_inventory = false
	$CollisionShape2D.disabled = true
	$Components/HitboxComp.team = 0
	visuals.deactivate()

func _on_damage_taken_prop_changed(_from: float, _to: float) -> void:
	health_changed.emit()
