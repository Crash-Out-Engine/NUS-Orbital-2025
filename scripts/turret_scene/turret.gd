class_name Turret
extends StaticBody2D

signal state_changed(from: State, to: State)
signal build_progressed(progress: float)
signal entity_spawned(Node2D)

enum State {
	DEFAULT,
	PLACING_VALID,
	PLACING_INVALID,
	PLANNED,
	OPERATIONAL,
	DESTROYED,
	CANCELLED,
}

const _LOOT_SCENE = preload("res://scenes/loot.tscn")

@export var build_target: float

@export_group("Properties")
@export var health_capacity: HealthCapacityProp
@export var health: HealthProp
@export var build: BuildProp

@export_group("Components")
@export var ranged: RangedBaseComp
@export var hitbox: HitboxComp
@export var mod_slots: ModSlotComp

## Stores the node path of the player_path that interacts with this turret.
var player_path: NodePath
var highlighted = false
var _state: State:
	set(value):
		var prev_state = _state
		_state = value
		if prev_state != _state:
			_sync()
			_handle_state_changed(prev_state, _state)
			state_changed.emit(prev_state, _state)
var _syncing: bool = false

@onready var _initial_team: Enums.Team = hitbox.team


func _ready() -> void:
	ranged.bullet_spawned.connect(entity_spawned.emit)
	health.emptied.connect(
			func():
				if is_multiplayer_authority():
					_state = State.DESTROYED
	)
	build.changed.connect(_check_build)
	hitbox.hit_by.connect(_check_repair)


func _physics_process(_delta: float) -> void:
	if !player_path.is_empty() and _state in [State.PLACING_INVALID, State.PLACING_VALID]:
		var player := get_tree().root.get_node(player_path)
		if player.is_multiplayer_authority():
			player.current_turret = self
			global_position = get_global_mouse_position()
			_sync()
			if !_can_place(player):
				set_state(State.PLACING_INVALID)
			else:
				set_state(State.PLACING_VALID)

func set_state(value: State) -> void:
	_state = value

func try_plan() -> bool:
	if _state == State.PLACING_VALID:
		advance_state()
		player_path = NodePath()
		return true
	if _state == Turret.State.PLACING_INVALID:
		set_state(State.CANCELLED)
		return false

	assert(false, "try_planned should not be called with state %s" % State.find_key(_state))
	return false


func advance_state() -> void:
	match _state:
		State.PLACING_VALID:
			_state = State.PLANNED
		State.PLANNED:
			_state = State.OPERATIONAL
		State.OPERATIONAL:
			_state = State.DESTROYED
		_:
			assert(false, "State should not advance at %s." % State.find_key(_state))

func disassemble():
	_state = State.DESTROYED
	for mod in mod_slots.get_mods():
		var loot = _LOOT_SCENE.instantiate()
		loot.setup_mod_loot(mod)
		loot.global_position = global_position
		entity_spawned.emit(loot)
	var levels = mod_slots._capacity - mod_slots.initial_capacity
	var scraps = _LOOT_SCENE.instantiate()
	scraps.setup_scrap_loot((levels + 1) * levels * mod_slots.upgrade_cost * 0.4)
	scraps.global_position = global_position
	entity_spawned.emit(scraps)


func _handle_state_changed(from: State, to: State):
	match [from, to]:
		[_, State.PLACING_VALID], [_, State.PLACING_INVALID]:
			_set_collidable(false)
			ranged.active = false
			hitbox.team = Enums.Team.NONE

		[State.PLACING_VALID, State.PLANNED]:
			_set_collidable(true)
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			hitbox.team = Enums.Team.TO_BUILD

		[_, State.OPERATIONAL]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			hitbox.team = _initial_team
			ranged.active = true

		[_, State.DESTROYED]:
			#TODO: implement loot drops
			get_parent().remove_entity(self)

		[_, State.CANCELLED]:
			get_parent().remove_entity(self)

		[_, _]:
			assert(false,
					"Invalid _state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func _set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)


func _is_overlapping() -> bool:
	return ($PlacementArea
			.get_overlapping_bodies()
			.any(func(body): return body.has_node(^"Components/HitboxComp")))

func _check_build(_from: float, to: float) -> void:
	if _state == State.PLANNED:
		if to >= build_target:
			_state = State.OPERATIONAL
		build_progressed.emit(to / build_target)

func _check_repair(entity: Node2D, effects: Array[Effect]) -> void:
	var build_effect_index = (
			effects.find_custom(func(effect: Effect): return effect.get_property_type() == "BuildProp"))
	if not (_state == State.OPERATIONAL and build_effect_index != -1 and entity is Player):
		return

	var player := entity as Player
	var build_effect = effects[build_effect_index]
	var cost = clamp(
			min(build_effect.get_factor() * 10, health_capacity.value - health.value) / 20,
			0,
			player.get_scraps())
	player.use_scraps(cost)
	health.value += cost * 20


func _can_place(player: Player) -> bool:
	return (!_is_overlapping() and player.turret_cost <= player.get_scraps())

func get_analysis() -> String:
	var analysis = "Health:%d/%d\nFire interval:%0.2fs\n" % [
			$Properties/HealthProp.value,
			$Properties/HealthCapacityProp.value,
			$Properties/RangedCooldownProp.value]
	if $Properties/CopyProp.value > 1:
		analysis += "Bullets/Shot:%d\nSpread:%d deg\n" % [
			$Properties/CopyProp.value,
			$Properties/SpreadProp.value]
	return analysis

#region Sync

func _sync() -> void:
	if not is_node_ready():
		await ready
	if _syncing:
		return

	while (!get_parent()._entity_count.has(self.get_path())
			or get_parent()._entity_count[self.get_path()] < multiplayer.get_peers().size() + 1):
		await get_tree().process_frame
		if get_parent() == null: # TODO(multiplayer): check if this check can be removed
			return
	_receive_sync.rpc(save_scene())

@rpc("any_peer", "call_remote", "reliable")
func _receive_sync(data: PackedByteArray) -> void:
	if !is_node_ready():
		await ready
	load_saved_scene(data)

#endregion


#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["_state"] = _state
	dict["player_path"] = player_path
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	_syncing = true
	var dict = bytes_to_var(data)
	position = dict["position"]
	_state = dict["_state"]
	player_path = dict["player_path"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])
	_syncing = false

#endregion
