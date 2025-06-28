extends Control

@export var _multiplayer_manager: MultiplayerManager

var _waiting: bool = false
var _hosting: bool = false

@onready var _host_button := $Panel/MarginContainer/VBoxContainer/HBoxContainer/Host as Button
@onready var _join_button := $Panel/MarginContainer/VBoxContainer/HBoxContainer/Join as Button
@onready var _start_button := $Panel/MarginContainer/VBoxContainer/Start as Button
@onready var _address := $Panel/MarginContainer/VBoxContainer/Address as LineEdit
@onready var _status_label := $Panel/StatusLabel as Label


func _ready() -> void:
	_reset()
	multiplayer.peer_connected.connect(func(_id): update_status())
	multiplayer.peer_disconnected.connect(func(_id): update_status())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		visible = false
		_reset()


func _on_texture_button_pressed() -> void:
	visible = false
	_reset()


func _reset() -> void:
	_waiting = false
	_hosting = false
	_enable_host_join()
	_disable_start()
	_address.text = "127.0.0.1"
	_status_label.text = ""


func update_status(error_message: String = "") -> void:
	if error_message.is_empty():
		var status: String
		if not _waiting:
			status = "Hosting" if _hosting else "Joining"
		else:
			status = ("Waiting for start (%d/%d)"
					% [_multiplayer_manager.ready_player_count, multiplayer.get_peers().size() + 1])

		_status_label.text = ("%s...\n%d player(s) here"
				% [status, (multiplayer.get_peers().size() + 1)])
	else:
		_status_label.text = error_message


func _enable_host_join() -> void:
	_host_button.disabled = false
	_join_button.disabled = false


func _disable_host_join() -> void:
	_host_button.disabled = true
	_join_button.disabled = true


func _enable_start() -> void:
	_start_button.disabled = false


func _disable_start() -> void:
	_start_button.disabled = true


func _on_host_pressed() -> void:
	if _multiplayer_manager.set_host():
		_hosting = true
		_disable_host_join()
		_enable_start()
		update_status()
	else:
		update_status("Can't host, address in use")


func _on_join_pressed() -> void:
	if _multiplayer_manager.set_client(_address.text):
		_disable_host_join()
		_enable_start()
		update_status()
	else:
		update_status("Address is invalid")


func _on_start_pressed() -> void:
	if _waiting == true:
		return

	_disable_start()
	_waiting = true
	_multiplayer_manager.player_ready(multiplayer.get_unique_id())
	update_status()
