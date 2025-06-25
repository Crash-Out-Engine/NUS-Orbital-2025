extends Node2D

signal disappear_finished

@export var fault: Fault

@onready var anim := $AnimatedSprite2D as AnimatedSprite2D
@onready var repair_bar := $RepairProgressBar as TextureProgressBar
@onready var rebooting_bar := $RebootingProgressBar as TextureProgressBar
@onready var status_label := $RebootingProgressBar/Label as Label
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	repair_bar.visible = false
	rebooting_bar.visible = false
	fault.state_changed.connect(_handle_state_changed)
	fault.repair_progressed.connect(_update_repair_progress)


func _process(_delta: float) -> void:
	if fault.state == Fault.State.REBOOTING:
		rebooting_bar.value = fault.get_time_progress_ratio() * 100


func _handle_state_changed(from: Fault.State, to: Fault.State) -> void:
	match [from, to]:
		[Fault.State.REBOOTING, Fault.State.SABOTAGED]:
			_play_sabotaged_label.rpc()

	match [to]:
		[Fault.State.REBOOTING]:
			_play_rebooting.rpc()

		[Fault.State.SABOTAGED]:
			_play_sabotaged.rpc()

		[Fault.State.FIXED]:
			_play_fixed.rpc()


@rpc("any_peer", "call_local", "reliable")
func _play_rebooting():
	anim.play("rebooting")
	status_label.text = "REBOOTING"
	anim_player.play("display_reboot")
	repair_bar.visible = false
	rebooting_bar.visible = true


@rpc("any_peer", "call_local", "reliable")
func _play_fixed():
	status_label.text = "FIXED"
	rebooting_bar.value = 100
	anim_player.play("fixed")


@rpc("any_peer", "call_local", "reliable")
func _play_sabotaged_label():
	anim_player.play("sabotaged")


@rpc("any_peer", "call_local", "reliable")
func _play_sabotaged():
	anim.play("sabotaged")
	rebooting_bar.visible = false
	repair_bar.visible = false


func _emit_disappear_finished():
	disappear_finished.emit()


func _update_repair_progress(progress: float):
	repair_bar.value = progress * 100
	if repair_bar.value > 0:
		repair_bar.scale = Vector2i(1, 1)
		repair_bar.visible = true
