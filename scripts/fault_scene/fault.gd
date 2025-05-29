class_name Fault
extends StaticBody2D

signal state_changed(from: State, to: State)
signal repair_progressed(progress: float)

enum State {
	SABOTAGED,
	REBOOTING,
	FIXED
}

@export var repair_target : float
@export var repair_prop : RepairProp
@export var sabotage_prop : SabotageProp
@export var hitbox : HitboxComp

var _power_output

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
	repair_prop.just_changed.connect(check_repair)
	sabotage_prop.just_changed.connect(check_sabotage)

func handle_state_changed(from: State, to: State):
	match [from, to]:
		[State.SABOTAGED, State.REBOOTING]:
			reboot_timer.start()
			hitbox.team = Enums.Team.REBOOTING_FAULT
			sabotage_prop.repair()
		
		[State.REBOOTING, State.SABOTAGED]:
			reboot_timer.stop()
			hitbox.team = Enums.Team.SABOTAGED_FAULT
		
		[State.REBOOTING, State.FIXED]:
			hitbox.team = Enums.Team.NONE
		
		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])

func set_power_output(node) -> void:
	_power_output = node

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
	_power_output.power += 20
	queue_free()
