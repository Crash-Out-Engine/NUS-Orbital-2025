class_name Fault
extends StaticBody2D

signal state_changed(from: State, to: State)
signal repair_progressed(progress: float)
signal fixed()

enum State {
	SABOTAGED,
	REBOOTING,
	FIXED
}

@export var repair_target: float

@export_group("Components")
@export var build_prop: BuildProp
@export var sabotage_prop: SabotageProp
@export var hitbox: HitboxComp

var state: State:
	set(value):
		var prev_state = state
		state = value
		if prev_state != state:
			handle_state_changed(prev_state, state)
			state_changed.emit(prev_state, state)

@onready var reboot_timer := $RebootTimer as Timer


func _ready() -> void:
	state = State.SABOTAGED
	build_prop.changed.connect(func(_from, to): check_repair(to))
	sabotage_prop.changed.connect(func(_from, to): check_sabotage(to))


func handle_state_changed(from: State, to: State):
	match [from, to]:
		[State.SABOTAGED, State.REBOOTING]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			reboot_timer.start()
			hitbox.team = Enums.Team.PLAYER_BUILDING
			sabotage_prop.reset()

		[State.REBOOTING, State.SABOTAGED]:
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			reboot_timer.stop()
			hitbox.team = Enums.Team.TO_BUILD
			build_prop.reset()

		[State.REBOOTING, State.FIXED]:
			hitbox.team = Enums.Team.NONE
			fixed.emit()

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func check_repair(value: float) -> void:
	if state == State.SABOTAGED:
		if value >= repair_target:
			state = State.REBOOTING
		repair_progressed.emit(value / repair_target)


func check_sabotage(new_value: bool) -> void:
	if new_value:
		state = State.SABOTAGED


func get_time_progress_ratio() -> float:
	return 1 - (reboot_timer.time_left / reboot_timer.wait_time)


func _on_reboot_timer_timeout() -> void:
	state = State.FIXED


func _on_visuals_disappear_finished() -> void:
	queue_free()
