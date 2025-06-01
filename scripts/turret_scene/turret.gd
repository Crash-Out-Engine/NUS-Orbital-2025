class_name Turret
extends StaticBody2D

signal state_changed(from: State, to: State)
signal build_progressed(progress: float)

enum State {
	DEFAULT,
	PLACING,
	PLANNED,
	OPERATIONAL,
	DESTROYED,
	CANCELLED,
}

@export var build_target: float

@export_group("Properties")
@export var health_capacity: HealthCapacityProp
@export var health: HealthProp
@export var build_prop: BuildProp

@export_group("Components")
@export var ranged: RangedBaseComp
@export var hitbox: HitboxComp

var state: State:
	set(value):
		var prev_state = state
		state = value
		if prev_state != state:
			handle_state_changed(prev_state, state)
			state_changed.emit(prev_state, state)
var player: Player

@onready var _team: Enums.Team = hitbox.team


func _ready() -> void:
	state = State.PLACING
	health.emptied.connect(func(): state = State.DESTROYED)
	build_prop.changed.connect(build_or_repair)


func advance_state():
	match state:
		State.PLACING:
			state = State.PLANNED
		State.PLANNED:
			state = State.OPERATIONAL
		State.OPERATIONAL:
			state = State.DESTROYED
		_:
			assert(false, "State should not advance at %s." % State.find_key(state))

	return state


func handle_state_changed(from: State, to: State):
	match [from, to]:
		[_, State.PLACING]:
			set_collidable(false)
			ranged.active = false
			hitbox.team = Enums.Team.NONE

		[_, State.PLANNED]:
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
			queue_free()

		[_, State.CANCELLED]:
			queue_free()

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])
	

func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)


func is_overlapping() -> bool:
	return $PlacementArea.get_overlapping_bodies().any(func(body): return body.get_node_or_null(^"Components/HitboxComp") != null)


func build_or_repair(from: float, to: float) -> void:
	if state == State.PLANNED:
		if to >= build_target:
			state = State.OPERATIONAL
		build_progressed.emit(to / build_target)
	if state == State.OPERATIONAL:
		var cost = min(player.scrap, min((to - from) * 10, health_capacity.value - health.value) / 20)
		player.scrap -= cost
		health.value += cost * 20
