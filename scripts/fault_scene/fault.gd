class_name Fault
extends StaticBody2D

signal state_changed(from: State, to: State)
signal repair_progressed(progress: float)
signal fixed()

enum State {
	DEFAULT,
	SABOTAGED,
	REBOOTING,
	FIXED
}

@export var repair_target: float

@export_group("Properties")
@export var build: BuildProp
@export var health: HealthProp
@export var health_capacity: HealthCapacityProp

@export_group("Components")
@export var hitbox: HitboxComp

var state: State:
	set(value):
		var prev_state = state
		state = value
		if prev_state != state:
			_handle_state_changed(prev_state, state)
			state_changed.emit(prev_state, state)

@onready var reboot_timer := $RebootTimer as Timer


func _ready() -> void:
	if state == State.DEFAULT:
		state = State.SABOTAGED
	build.changed.connect(func(_from, to): _check_repair(to))
	health.emptied.connect(func(): state = State.SABOTAGED)


func get_time_progress_ratio() -> float:
	return 1 - (reboot_timer.time_left / reboot_timer.wait_time)


func _handle_state_changed(from: State, to: State):
	match [from, to]:
		[var x, State.REBOOTING] when x in [State.DEFAULT, State.SABOTAGED]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			if reboot_timer != null:
				reboot_timer.start()
			hitbox.team = Enums.Team.PLAYER_BUILDING
			health.value = health_capacity.value

		[var x, State.SABOTAGED] when x in [State.DEFAULT, State.REBOOTING]:
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			if reboot_timer != null:
				reboot_timer.stop()
			hitbox.team = Enums.Team.TO_BUILD
			build.reset()

		[State.REBOOTING, State.FIXED]:
			hitbox.team = Enums.Team.NONE
			fixed.emit()

		[State.DEFAULT, State.FIXED]:
			hitbox.team = Enums.Team.NONE

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func _check_repair(value: float) -> void:
	if state == State.SABOTAGED:
		if value >= repair_target:
			state = State.REBOOTING
		repair_progressed.emit(value / repair_target)


func _check_sabotage(new_value: bool) -> void:
	if new_value:
		state = State.SABOTAGED


func _on_reboot_timer_timeout() -> void:
	state = State.FIXED


func _on_visuals_disappear_finished() -> void:
	get_parent().remove_entity(self)

#region Save/load

func save_scene() -> PackedByteArray:
	var dict := {}
	dict["global_position"] = global_position
	dict["state"] = state
	dict["build.value"] = build.value
	dict["reboot_timer.time_left"] = reboot_timer.time_left
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	global_position = dict["global_position"]
	if !is_node_ready():
		await ready
	state = dict["state"]
	match state:
		State.SABOTAGED:
			build.value = dict["build.value"]
		State.REBOOTING:
			reboot_timer.start(dict["reboot_timer.time_left"])

#endregion
