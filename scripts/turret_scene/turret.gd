class_name Turret
extends StaticBody2D

signal state_changed(from: State, to: State)

enum State {
	DEFAULT,
	PLACING,
	PLANNED,
	BUILDING,
	OPERATIONAL,
	DESTROYED,
	CANCELLED,
}

@export_group("Properties")
@export var target_priority: TargetPriorityProp
@export var health: HealthProp

@export_group("Components")
@export var ranged: RangedBaseComp


var state: State:
	set(value):
		var prev_state = state
		state = value
		if prev_state != state:
			handle_state_changed(prev_state, state)
			state_changed.emit(prev_state, state)
var player: Player

@onready var _team: String = target_priority.team


func _ready() -> void:
	state = State.PLACING
	health.just_emptied.connect(func(): state = State.DESTROYED)


func advance_state():
	match state:
		State.PLACING:
			state = State.PLANNED
		State.PLANNED:
			state = State.BUILDING
		State.BUILDING:
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
			target_priority.team = ""

		[_, State.PLANNED]:
			set_collidable(true)
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)

		[_, State.BUILDING]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			target_priority.team = _team

		[_, State.OPERATIONAL]:
			ranged.active = true

		[_, State.DESTROYED]:
			if (player != null): # HACK: turret should not call player code (not that often, at least)
				player.turrets_placed -= 1
				player.turret_cost = (player.turrets_placed + 1) * player.turrets_placed * 5 / 2
			queue_free()

		[_, State.CANCELLED]:
			queue_free()

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)


func is_overlapping() -> bool:
	return $PlacementArea.get_overlapping_bodies().any(func(body): return body.get_node_or_null(^"Components/HitboxComp") != null)
