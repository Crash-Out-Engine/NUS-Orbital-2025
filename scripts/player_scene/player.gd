class_name Player
extends RigidBody2D

signal entity_spawned(entity: Node2D)
signal turret_placement_failed()
signal health_changed()
signal scraps_changed()
signal lives_depleted()
signal state_changed(from: State, to: State)

enum State {
	PLAYING,
	INVENTORY,
	DEAD,
	LOST,
}

const _TURRET_SCENE := preload("res://scenes/turret.tscn")

@export_group("Properties")
@export var health: HealthProp
@export var health_capacity: HealthCapacityProp
@export var melee_cooldown: MeleeCooldownProp
@export var size_prop: SizeProp
@export var lives: RepeatProp

@export_group("Components")
@export var ranged: RangedBaseComp
@export var melee_attack: MeleeComp
@export var melee_repair: MeleeComp
@export var inventory: InventoryComp
@export var mod_slots: ModSlotComp
@export var blueprints: BlueprintComp

var state: State = State.PLAYING:
	set(value):
		if value != state:
			var prev_value = state
			state = value
			_handle_state_changed(prev_value, value)
			state_changed.emit(prev_value, value)
var hand: Hand = Hand.new()
var current_turret = null
var turret_cost = 25
var _melee_active: bool = false # HACK: Prefer not to use this variable.
var _ranged_active: bool = false

@onready var visuals := $Visuals as PlayerVisuals


func _ready() -> void:
	inventory.scraps_changed.connect(func(_from: int, _to: int): scraps_changed.emit())
	health.changed.connect(func(_from: int, _to: int): health_changed.emit())
	ranged.bullet_spawned.connect(entity_spawned.emit)
	visuals.melee_finished.connect(
			func():
				if (is_multiplayer_authority()
						and hand.action == Hand.Action.FIRING_WRENCH
						and hand.unlock()):
					hand.action = Hand.Action.HOLDING_WRENCH
	)
	hand.action_changed.connect(_handle_hand_action_changed)
	hand.changed.connect(_sync_hand)


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	const HA = Hand.Action
	if (_melee_active
			and melee_cooldown.can_melee()
			and hand.action in [HA.HOLDING_GUN, HA.HOLDING_WRENCH]):
		hand.action = HA.FIRING_WRENCH
		hand.lock()

	if (!_melee_active and hand.action == HA.HOLDING_WRENCH):
		hand.action = HA.HOLDING_GUN

	if _ranged_active and hand.action == HA.HOLDING_GUN:
		hand.action = HA.FIRING_GUN

	hand.rotation = get_local_mouse_position().angle()

	if current_turret != null:
		current_turret.global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	const HA = Hand.Action
	if (event.is_action_pressed("add turret")
			and hand.action in [HA.HOLDING_GUN, HA.FIRING_GUN, HA.HOLDING_WRENCH]):
		hand.action = HA.PLANNING_WRENCH
	if event.is_action_pressed("shoot"):
		_ranged_active = true
	if event.is_action_released("shoot"):
		_ranged_active = false

	if event.is_action_pressed("melee"):
		_melee_active = true
	if (event.is_action_released("melee")):
		_melee_active = false

	if ((event.is_action_released("add turret") and hand.action == HA.PLANNING_WRENCH)
			or (event.is_action_released("shoot") and hand.action == HA.FIRING_GUN)):
		hand.action = HA.HOLDING_GUN


# region forwarding

func get_analysis() -> String:
	var analysis = "Health:%d/%d\nFire interval:%0.2fs\n" % [
			$Properties/HealthProp.value,
			$Properties/HealthCapacityProp.value,
			$Properties/RangedCooldownProp.value]
	if $Properties/CopyProp.value > 1:
		analysis += "Bullets/Shot:%d\nSpread:%d deg\n" % [
			$Properties/CopyProp.value,
			$Properties/SpreadProp.value]
	analysis += "Melee interval:%0.2fs\nSpeed:%d" % [
			$Properties/MeleeCooldownProp.value,
			$Properties/SpeedProp.value]
	if $Properties/KnockbackResistanceProp.value != 1:
		analysis += "\nKnockback resistance:%d" % $Properties/KnockbackResistanceProp.value
	if $Properties/SizeProp.value != 1:
		analysis += "\nSize:%0.2f" % $Properties/SizeProp.value
	if $Properties/RepeatProp.value > 1:
		analysis += "\nLives:%d" % $Properties/RepeatProp.value
	return analysis

func get_health() -> float:
	return health.value


func get_health_capacity() -> float:
	return health_capacity.value


func get_scraps() -> int:
	return inventory.get_scraps()


func use_scraps(amount: int) -> void:
	inventory.use_scraps(amount)


func get_blueprints() -> Array[ModBase]:
	return blueprints.get_blueprints()


func get_inventory() -> InventoryComp:
	return inventory


# endregion


func _handle_state_changed(_from: State, to: State) -> void:
	if not is_multiplayer_authority():
		return

	match to:
		State.INVENTORY:
			if current_turret != null:
				current_turret.set_state(Turret.State.CANCELLED)
			hand.unlock()
			hand.action = Hand.Action.HOLDING_GUN
			hand.lock()
			$Components/MovementComp.active = false
		State.PLAYING:
			hand.unlock()
			$Components/MovementComp.active = true
		State.LOST, State.DEAD:
			hand.unlock()
			hand.action = Hand.Action.HOLDING_GUN
			hand.lock()
			$CollisionShape2D.disabled = true
			$Components/MovementComp.active = false
			ranged.active = false
			$Components/HitboxComp.team = 0


func _handle_hand_action_changed(from: Hand.Action, to: Hand.Action) -> void:
	if not is_multiplayer_authority():
		return
	const HA = Hand.Action

	match from:
		HA.FIRING_GUN:
			ranged.active = false

	match [from, to]:
		[ var x, HA.PLANNING_WRENCH] when x in [HA.HOLDING_GUN, HA.HOLDING_WRENCH, HA.FIRING_GUN]:
			current_turret = _TURRET_SCENE.instantiate()
			current_turret.player_path = get_path()
			current_turret.global_position = get_global_mouse_position()
			current_turret.set_state(Turret.State.PLACING_VALID)
			entity_spawned.emit(current_turret)
		[HA.PLANNING_WRENCH, HA.HOLDING_GUN]:
			if current_turret != null:
				if current_turret.try_plan():
					inventory.use_scraps(turret_cost)
				else:
					turret_placement_failed.emit()
				current_turret = null
		[ var x, HA.FIRING_WRENCH] when x in [HA.HOLDING_GUN, HA.HOLDING_WRENCH]:
			melee_attack.rotation = hand.rotation
			melee_repair.rotation = hand.rotation
			melee_attack.activate()
			melee_repair.activate()
		[HA.HOLDING_GUN, HA.FIRING_GUN], [HA.FIRING_WRENCH, HA.HOLDING_WRENCH], [_, HA.HOLDING_GUN]:
			pass
		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [HA.find_key(from), HA.find_key(to)])


	match to:
		HA.FIRING_GUN:
			ranged.active = true


func _on_health_emptied() -> void:
	if lives.check_empty():
		state = State.DEAD
		lives_depleted.emit()
	else:
		respawn()


func respawn() -> void:
	health.value = 10 # HACK: create proper respawn sequence


func deactivate():
	if not state in [State.LOST, State.DEAD]:
		state = State.LOST

#region Sync

func _sync_hand() -> void:
	if not is_multiplayer_authority():
		return

	_receive_hand_sync.rpc(hand.save())

@rpc("any_peer", "call_remote", "reliable")
func _receive_hand_sync(data: PackedByteArray) -> void:
	hand.load_saved(data)

#endregion

#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["state"] = state
	dict["hand"] = hand.save()
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	state = dict["state"]
	hand.load_saved(dict["hand"])
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion

class Hand:
	signal changed()
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
	var rotation: float:
		set(value):
			if locked:
				return
			rotation = value
			changed.emit()


	func _init():
		action = Action.HOLDING_GUN


	func _set_action(value: Action) -> void:
		if locked:
			return
		var prev_value = action
		if prev_value != value:
			action = value
			changed.emit()
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


	#region Save/load

	func save() -> PackedByteArray:
		var dict = {}
		dict["rotation"] = rotation
		dict["action"] = action
		return var_to_bytes(dict)


	func load_saved(data: PackedByteArray) -> void:
		var dict := bytes_to_var(data) as Dictionary
		rotation = dict["rotation"]
		action = dict["action"]

	#endregion
