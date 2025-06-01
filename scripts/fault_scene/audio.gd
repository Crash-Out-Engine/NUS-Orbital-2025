extends Node

@export var fault: Fault

@onready var sabotaged_sound := $SabotagedSound as AudioStreamPlayer
@onready var success_sound := $SuccessSound as AudioStreamPlayer


func _ready() -> void:
	fault.state_changed.connect(handle_state_changed)

func handle_state_changed(from: Fault.State, to: Fault.State):
	match [from, to]:
		[Fault.State.REBOOTING, Fault.State.SABOTAGED]:
			sabotaged_sound.play()

		[Fault.State.REBOOTING, Fault.State.FIXED]:
			success_sound.play()
