class_name Player
extends RigidBody2D

signal turret_placement_failed()
signal health_changed()
signal scraps_changed()
signal entity_spawned(entity: Node2D)

const _TURRET_SCENE := preload("res://scenes/turret.tscn")

@export_group("Properties")
@export var health: HealthProp
@export var health_capacity: HealthCapacityProp

@export_group("Components")
@export var ranged: RangedBaseComp
@export var melee: MeleeComp
@export var repair: MeleeComp
@export var inventory: InventoryComp

var hand: Hand = Hand.new()
var current_turret: Turret = null
var turret_cost = 25

@onready var melee_player := $MeleePlayer as AnimationPlayer


func _ready() -> void:
	inventory.scraps_changed.connect(func(_from, _to): scraps_changed.emit())
	ranged.bullet_spawned.connect(entity_spawned.emit)
	melee_player.animation_finished.connect(func(_name):
			if is_multiplayer_authority():
				hand.unlock()
				hand.action = Hand.Action.HOLDING_WRENCH
				sync_hand.rpc(hand.save()))
	hand.action_changed.connect(_handle_hand_action_changed)


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		const HA = Hand.Action

		if (Input.is_action_pressed("add turret")
				and hand.action in [HA.HOLDING_GUN, HA.FIRING_GUN, HA.HOLDING_WRENCH]):
			hand.action = HA.PLANNING_WRENCH
		elif (Input.is_action_pressed("melee")
				and hand.action in [HA.HOLDING_GUN, HA.HOLDING_WRENCH]):
			hand.action = HA.FIRING_WRENCH
			hand.lock()
		elif (Input.is_action_pressed("shoot")
				and hand.action == HA.HOLDING_GUN):
			hand.action = HA.FIRING_GUN
		elif ((Input.is_action_just_released("add turret")
						and hand.action == HA.PLANNING_WRENCH)
				or (!Input.is_action_pressed("melee")
						and hand.action == HA.HOLDING_WRENCH)
				or (Input.is_action_just_released("shoot")
						and hand.action == HA.FIRING_GUN)):
			hand.action = HA.HOLDING_GUN

		hand.rotation = get_local_mouse_position().angle()

		sync_hand.rpc(hand.save())

		if current_turret != null:
			current_turret.global_position = get_global_mouse_position()
			if !_can_place_turret():
				current_turret.call_deferred("set_state", Turret.State.PLACING_INVALID)
			else:
				current_turret.call_deferred("set_state", Turret.State.PLACING_VALID)


# HACK: Temporary for testing, @deltaMinor please remove
func add_random_mod(turret: Turret) -> void:
	if (turret.has_node(^"Components/ModSlotComp")
			and turret.get_node(^"Components/ModSlotComp").get_mods().find(null) == -1):
		assert(false, "WOT?")
	var inventory_mods = inventory.get_mods()
	for key: ModBase in inventory_mods.keys():
		if inventory_mods[key] > 0:
			inventory.access_entity(turret)
			inventory._handle_mod_equipped(key)
			inventory.unaccess_entity()
			return

@rpc("any_peer", "call_remote", "reliable")
func sync_hand(data: PackedByteArray) -> void:
	hand.load_saved(data)


#region forwarding


func get_health() -> float:
	return health.value


func get_health_capacity() -> float:
	return health_capacity.value


func get_scraps() -> int:
	return inventory.get_scraps()


func use_scraps(amount: int) -> void:
	inventory.use_scraps(amount)


#endregion


func _handle_hand_action_changed(from: Hand.Action, to: Hand.Action) -> void:
	const HA = Hand.Action

	match from: # First deactivate ranged component.
		HA.FIRING_GUN:
			ranged.active = false

	match [from, to]: # Then handle changes.
		[ var x, HA.PLANNING_WRENCH] when x in [HA.HOLDING_GUN, HA.HOLDING_WRENCH, HA.FIRING_GUN]:
			if is_multiplayer_authority():
				var turret = _TURRET_SCENE.instantiate()
				turret.placing_player = get_path()
				turret.set_state(Turret.State.PLACING_VALID)
				entity_spawned.emit(turret)
		[HA.PLANNING_WRENCH, HA.HOLDING_GUN]:
			if is_multiplayer_authority() and current_turret != null:
				if _can_place_turret():
					current_turret.advance_state()
					inventory.use_scraps(turret_cost)
					# add_random_mod(current_turret)
					# add_random_mod(current_turret)
				else:
					current_turret.set_state(Turret.State.CANCELLED)
					turret_placement_failed.emit()
				current_turret = null
		[var x, HA.FIRING_WRENCH] when x in [HA.HOLDING_GUN, HA.HOLDING_WRENCH]:
			melee.rotation = hand.rotation
			repair.rotation = hand.rotation
			melee_player.play("melee_attack")
		[HA.HOLDING_GUN, HA.FIRING_GUN]:
			ranged.active = true
		[HA.FIRING_WRENCH, HA.HOLDING_WRENCH]:
			pass
		[HA.HOLDING_WRENCH, HA.HOLDING_GUN]:
			pass
		[HA.FIRING_GUN, HA.HOLDING_GUN]:
			pass
		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [HA.find_key(from), HA.find_key(to)])


func _can_place_turret() -> bool:
	return (current_turret != null
			and !current_turret.is_overlapping()
			and turret_cost <= inventory.get_scraps())


func _on_health_emptied() -> void:
	get_tree().reload_current_scene()


func _on_health_changed(_from: float, _to: float) -> void:
	health_changed.emit()

#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion

class Hand:

	signal action_changed(from: Action, to: Action)

	enum Action {
		HOLDING_GUN,
		FIRING_GUN,
		HOLDING_WRENCH,
		FIRING_WRENCH,
		PLANNING_WRENCH,
	}

	var locked: bool = false
	var action: Action:
		set = _set_action
	var rotation: float


	func _init() -> void:
		action = Action.HOLDING_GUN


	func _set_action(value: Action) -> void:
		if locked:
			return
		var prev_value = action
		if prev_value != value:
			action = value
			action_changed.emit(prev_value, value)


	func lock() -> bool:
		if locked:
			return false

		locked = true
		return true


	func unlock() -> bool:
		if !locked:
			return false

		locked = false
		return true


	func save() -> PackedByteArray:
		var dict = {}
		dict["rotation"] = rotation
		dict["action"] = action
		return var_to_bytes(dict)

	func load_saved(data: PackedByteArray) -> void:
		var dict := bytes_to_var(data) as Dictionary
		rotation = dict.rotation
		action = dict.action
