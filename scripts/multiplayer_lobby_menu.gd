extends Control

@export var _multiplayer_manager: MultiplayerManager

var state
var _waiting: bool = false

@onready var _host_button := $Panel/MarginContainer/VBoxContainer/HBoxContainer/Host as Button
@onready var _join_button := $Panel/MarginContainer/VBoxContainer/HBoxContainer/Join as Button
@onready var _start_button := $Panel/MarginContainer/VBoxContainer/Start as Button
@onready var _address := $Panel/MarginContainer/VBoxContainer/Address as LineEdit
@onready var _status_label := $Panel/StatusLabel as Label


func _ready() -> void:
	_reset()
	_multiplayer_manager.player_joined.connect(update_status)
	_multiplayer_manager.ready_players_changed.connect(update_status)
	_multiplayer_manager.server_disconnected.connect(func():
			_reset()
			update_status("Host disconnected")
	)
	_multiplayer_manager.player_disconnected.connect(func():
			update_status()
	)
	_multiplayer_manager.state_changed.connect(func(_from, _to): update_status())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		visible = false
		_reset()


func _on_texture_button_pressed() -> void:
	visible = false
	_reset()


func _reset() -> void:
	_waiting = false
	_address.text = "127.0.0.1"
	update_status()
	_multiplayer_manager.disconnect_multiplayer()


func update_status(error_message: String = "") -> void:
	match _multiplayer_manager.state:
		MultiplayerManager.State.DEFAULT:
			_enable_host_join()
			_disable_start()
		MultiplayerManager.State.HOSTING:
			_disable_host_join()
			_enable_start()
		MultiplayerManager.State.JOINING:
			_disable_host_join()
		MultiplayerManager.State.JOINED:
			_enable_start()
		MultiplayerManager.State.READY:
			_disable_start()

	var front_text: String
	match _multiplayer_manager.state:
		MultiplayerManager.State.DEFAULT:
			front_text = error_message
		MultiplayerManager.State.HOSTING:
			front_text = "Hosting"
		MultiplayerManager.State.JOINING:
			front_text = "Joining"
		MultiplayerManager.State.JOINED:
			front_text = "Joined"
		MultiplayerManager.State.READY:
			front_text = ("Waiting for start (%d/%d)"
					% [_multiplayer_manager.get_ready_count(), _multiplayer_manager.get_player_count()])
		MultiplayerManager.State.ALL_READY:
			front_text = "Starting"
			if is_multiplayer_authority():
				_multiplayer_manager.start_game_for_all()

	var back_text: String
	match _multiplayer_manager.state:
		MultiplayerManager.State.HOSTING,\
		MultiplayerManager.State.JOINED,\
		MultiplayerManager.State.READY,\
		MultiplayerManager.State.ALL_READY:
			back_text = ("%d player(s) here" % _multiplayer_manager.get_player_count())

	_status_label.text = "%s\n%s" % [front_text, back_text]


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
		update_status()
	else:
		update_status("Can't host, address in use")


func _on_join_pressed() -> void:
	if _multiplayer_manager.set_client(_address.text):
		update_status()
	else:
		update_status("Address is invalid")


func _on_start_pressed() -> void:
	if _waiting == true:
		return

	_waiting = true
	_multiplayer_manager.set_player_ready()
	update_status()
