extends Node2D

signal disappear_finished

@export var fault: Fault

@onready var anim := $AnimatedSprite2D as AnimatedSprite2D
@onready var repair_bar := $RepairProgressBar as TextureProgressBar
@onready var rebooting_bar := $RebootingProgressBar as TextureProgressBar
@onready var status_label := $RebootingProgressBar/Label as Label
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	play_sabotaged()
	_handle_state_changed(fault.state, fault.state)
	fault.state_changed.connect(_handle_state_changed)
	fault.repair_progressed.connect(update_repair_progress)


func _process(_delta: float) -> void:
	if fault.state == Fault.State.REBOOTING:
		rebooting_bar.value = fault.get_time_progress_ratio() * 100


func _handle_state_changed(from: Fault.State, to: Fault.State) -> void:
	match [from, to]:
		[Fault.State.REBOOTING, Fault.State.SABOTAGED]:
			anim_player.play("sabotaged")

	match [from, to]:
		[_, Fault.State.REBOOTING]:
			play_rebooting()

		[_, Fault.State.SABOTAGED]:
			play_sabotaged()

		[_, Fault.State.FIXED]:
			play_fixed()


func play_rebooting():
	anim.play("rebooting")
	status_label.text = "REBOOTING"
	anim_player.play("display_reboot")
	repair_bar.visible = false
	rebooting_bar.visible = true


func play_fixed():
	status_label.text = "FIXED"
	rebooting_bar.value = 100
	anim_player.play("fixed")


func play_sabotaged():
	anim.play("sabotaged")
	rebooting_bar.visible = false
	repair_bar.visible = false


func emit_disappear_finished():
	disappear_finished.emit()


func update_repair_progress(progress: float):
	repair_bar.value = progress * 100
	if repair_bar.value > 0:
		repair_bar.scale = Vector2i(1, 1)
		repair_bar.visible = true
