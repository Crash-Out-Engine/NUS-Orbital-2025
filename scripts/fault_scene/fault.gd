class_name Fault
extends StaticBody2D

signal state_changed(from: State, to: State)
signal repair_progressed(progress: float)
signal reboot_finished()

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
	if state == State.DEFAULT: # If Fault is not loaded from SaveData
		state = State.SABOTAGED
	build.changed.connect(func(_from, to): check_repair(to))
	health.emptied.connect(func(): state = State.SABOTAGED)


func check_repair(value: float) -> void:
	if state == State.SABOTAGED:
		if value >= repair_target:
			state = State.REBOOTING
		repair_progressed.emit(value / repair_target)


func save_scene() -> PackedByteArray:
	var data := SaveData.new()
	data.position = global_position
	data.state = state
	data.build_value = build.value
	data.remaining_reboot_time = reboot_timer.time_left
	return var_to_bytes(data.to_dict())


func load_saved_scene(data: PackedByteArray) -> void:
	var save_data = SaveData.from_dict(bytes_to_var(data))
	global_position = save_data.position
	state = save_data.state
	if !is_node_ready():
		await ready
	match state:
		State.SABOTAGED:
			build.value = save_data.build_value
		State.REBOOTING:
			reboot_timer.start(save_data.remaining_reboot_time)
	return


func get_time_progress_ratio() -> float:
	return 1 - (reboot_timer.time_left / reboot_timer.wait_time)


func _handle_state_changed(from: State, to: State):
	match [from, to]:
		[State.DEFAULT, State.REBOOTING], [State.SABOTAGED, State.REBOOTING]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			if reboot_timer != null:
				reboot_timer.start()
			hitbox.team = Enums.Team.PLAYER_BUILDING
			health.value = 0.1

		[State.DEFAULT, State.SABOTAGED], [State.REBOOTING, State.SABOTAGED]:
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			if reboot_timer != null:
				reboot_timer.stop()
			hitbox.team = Enums.Team.TO_BUILD
			build.reset()

		[State.REBOOTING, State.FIXED]:
			hitbox.team = Enums.Team.NONE
			reboot_finished.emit()

		[State.DEFAULT, State.FIXED]:
			hitbox.team = Enums.Team.NONE

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func _on_reboot_timer_timeout() -> void:
	state = State.FIXED
	reboot_finished.emit()


func _on_visuals_disappear_finished() -> void:
	sync_queue_free()

#region Sync

func sync_queue_free() -> void:
	if get_parent().is_multiplayer_authority():
		queue_free()
	else:
		_remote_queue_free.rpc()
		
@rpc("any_peer", "call_remote", "reliable")
func _remote_queue_free() -> void:
	if get_parent().is_multiplayer_authority():
		queue_free()

#endregion

class SaveData: # TODO: Contemplate whether to remove this utility class
	var position: Vector2
	var state: State
	var remaining_reboot_time: float
	var build_value: float

	func to_dict() -> Dictionary:
		var dict := {}
		dict["position"] = position
		dict["state"] = state
		dict["remaining_reboot_time"] = remaining_reboot_time
		dict["build_value"] = build_value

		return dict

	static func from_dict(data: Dictionary) -> SaveData:
		var save_data := SaveData.new()
		save_data.position = data.position
		save_data.state = data.state
		save_data.remaining_reboot_time = data.remaining_reboot_time
		save_data.build_value = data.build_value

		return save_data
