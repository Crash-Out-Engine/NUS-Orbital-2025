class_name Fault
extends StaticBody2D

enum State {
	SABOTAGED,
	REBOOTING,
	FIXED
}

@onready var reboot_timer := $RebootTimer as Timer

@export var repair_target : float
@export var repair_prop : RepairProp
@export var hitbox : HitboxComp

var state: State:
	set(value):
		var prev_state = state
		state = value
		if prev_state != state:
			handle_state_changed(prev_state, state)
			state_changed.emit(prev_state, state)

signal state_changed(from: State, to: State)

func _ready() -> void:
	repair_prop.just_changed.connect(check_repair)


func handle_state_changed(from: State, to: State):
	match [from, to]:
		[State.SABOTAGED, State.REBOOTING]:
			reboot_timer.start()
			hitbox.team = Enums.Team.REBOOTING_FAULT
		
		[State.REBOOTING, State.SABOTAGED]:
			reboot_timer.stop()
			hitbox.team = Enums.Team.SABOTAGED_FAULT
		
		[State.REBOOTING, State.FIXED]:
			hitbox.team = Enums.Team.NONE
		
		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])

signal repair_progress(progress: float)

func check_repair(value: float) -> void:
	if state == State.SABOTAGED:
		if(value >= repair_target):
			state = State.REBOOTING
		repair_progress.emit(value / repair_target)



func _on_visuals_disappeared() -> void:
	queue_free()


func _on_reboot_timer_timeout() -> void:
	state = State.FIXED

func get_time_progress_ratio() -> float:
	return 1 - (reboot_timer.time_left / reboot_timer.wait_time)
