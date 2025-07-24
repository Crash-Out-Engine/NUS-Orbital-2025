class_name Fault
extends StaticBody2D

signal state_changed(from: State, to: State)
signal repair_progressed(progress: float)
signal fixed()

enum State {
	UNINITIALIZED,
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
	build.changed.connect(func(_from, _to): _check_repair())
	health.emptied.connect(func(): state = State.SABOTAGED)
	ready.connect(func():
		if state == State.UNINITIALIZED:
			state = State.SABOTAGED
	)


func get_time_progress_ratio() -> float:
	return 1 - (reboot_timer.time_left / reboot_timer.wait_time)


func _handle_state_changed(from: State, to: State):
	if not is_node_ready():
		await ready
	match [from, to]:
		[var x, State.REBOOTING] when x in [State.UNINITIALIZED, State.SABOTAGED]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			reboot_timer.start()
			hitbox.team = Enums.Team.PLAYER_BUILDING
			health.reset()

		[State.REBOOTING, State.SABOTAGED]:
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			reboot_timer.stop()
			hitbox.team = Enums.Team.TO_BUILD
			build.reset()
		
		[State.REBOOTING, State.FIXED]:
			hitbox.team = Enums.Team.NONE
			fixed.emit()

		[State.UNINITIALIZED, State.SABOTAGED]:
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			hitbox.team = Enums.Team.TO_BUILD
			_check_repair()
		
		[State.UNINITIALIZED, State.FIXED]:
			hitbox.team = Enums.Team.NONE

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func _check_repair() -> void:
	if state == State.SABOTAGED and build.value > 0:
		if build.value >= repair_target:
			state = State.REBOOTING
		repair_progressed.emit(build.value / repair_target)


func _on_reboot_timer_timeout() -> void:
	state = State.FIXED


func _on_visuals_disappear_finished() -> void:
	get_parent().server_remove_entity(self)


#region Save/load

func save_scene() -> PackedByteArray:
	var dict := {}
	dict["position"] = position
	dict["state"] = state
	dict["reboot_timer.time_left"] = reboot_timer.time_left
	for property_node: PropertyBase in $Properties.get_children():
		dict[property_node.name] = property_node.save()
	return var_to_bytes(dict)


func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	if not is_node_ready():
		await ready

	position = dict["position"]
	state = dict["state"]
	for property_node: PropertyBase in $Properties.get_children():
		property_node.load_saved(dict[property_node.name])
	
	if state == State.REBOOTING:
		reboot_timer.start(dict["reboot_timer.time_left"])


func load_preset(preset: FaultPreset) -> void:
	position = preset.position

#endregion
