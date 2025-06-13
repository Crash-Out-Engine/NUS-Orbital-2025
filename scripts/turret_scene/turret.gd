class_name Turret
extends StaticBody2D

signal state_changed(from: State, to: State)
signal build_progressed(progress: float)
signal entity_spawned(entity: Node2D)

enum State {
	DEFAULT,
	PLACING_INVALID,
	PLACING_VALID,
	PLANNED,
	OPERATIONAL,
	DESTROYED,
	CANCELLED,
}

const TURRET_COST := 25

@export var build_target: float

@export_group("Properties")
@export var health_capacity: HealthCapacityProp
@export var health: HealthProp
@export var build: BuildProp

@export_group("Components")
@export var ranged: RangedBaseComp
@export var hitbox: HitboxComp

var placing_player: NodePath
var _state: State:
	set(value):
		var prev_state = _state
		_state = value
		if prev_state != _state:
			call_deferred("_sync")
			handle_state_changed(prev_state, _state)
			state_changed.emit(prev_state, _state)

@onready var _team: Enums.Team = hitbox.team

func _ready() -> void:
	health.emptied.connect(func(): if is_multiplayer_authority(): _state = State.DESTROYED)
	build.changed.connect(build_or_repair)
	hitbox.hit_by.connect(check_repair)
	ranged.bullet_spawned.connect(entity_spawned.emit)


func _physics_process(_delta: float) -> void:
	if _state in [State.PLACING_INVALID, State.PLACING_VALID]:
		var player := get_tree().root.get_node(placing_player)
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			player.current_turret = self
			global_position = get_global_mouse_position()
			if !_can_place(player):
				call_deferred("set_state", Turret.State.PLACING_INVALID)
			else:
				call_deferred("set_state", Turret.State.PLACING_VALID)


func set_state(value: State) -> void:
	_state = value


func advance_state():
	match _state:
		State.PLACING_VALID:
			_state = State.PLANNED
		State.PLANNED:
			_state = State.OPERATIONAL
		State.OPERATIONAL:
			_state = State.DESTROYED
		_:
			assert(false, "State should not advance at %s." % State.find_key(_state))

	return _state


func handle_state_changed(from: State, to: State):
	match [from, to]:
		[_, State.PLACING_INVALID], [_, State.PLACING_VALID]:
			set_collidable(false)
			ranged.active = false
			hitbox.team = Enums.Team.NONE

		[State.PLACING_VALID, State.PLANNED]:
			set_collidable(true)
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			hitbox.team = Enums.Team.TO_BUILD

		[_, State.OPERATIONAL]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			hitbox.team = _team
			ranged.active = true

		[_, State.DESTROYED]:
			#TODO: implement loot drops
			get_parent().remove_entity(self)

		[_, State.CANCELLED]:
			get_parent().remove_entity(self)

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)


func is_overlapping() -> bool:
	return ($PlacementArea
			.get_overlapping_bodies()
			.any(func(body): return body.has_node(^"Components/HitboxComp")))

func _can_place(player: Player) -> bool:
	return (!is_overlapping()
			and TURRET_COST <= player.inventory.get_scraps())

func build_or_repair(_from: float, to: float) -> void:
	if _state == State.PLANNED:
		if to >= build_target:
			_state = State.OPERATIONAL
		build_progressed.emit(to / build_target)


func check_repair(entity: Node2D, effects: Array[Effect]) -> void:
	var build_effect_index = effects.find_custom(func(effect: Effect): return effect.type == Effect.Type.BUILD)
	if _state == State.OPERATIONAL and build_effect_index != -1 and entity is Player:
		var player := entity as Player
		var build_effect = effects[build_effect_index]
		var cost = clamp(
				min(build_effect._factor * 10, health_capacity.value - health.value) / 20,
				0,
				player.get_scraps()
			)
		player.use_scraps(cost)
		health.value += cost * 20
		health.value += cost * 20


#region Sync

func _sync() -> void:
	if get_parent() == null:
		return
	if !is_node_ready():
		await ready
	while get_parent()._entity_count[self.get_path()] < multiplayer.get_peers().size() + 1:
		await get_tree().process_frame
		if get_parent() == null:
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
	dict["placing_player"] = placing_player
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict["position"]
	_state = dict["_state"]
	placing_player = dict["placing_player"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])

#endregion
