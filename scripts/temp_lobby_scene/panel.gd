extends Panel

@export var multiplayer_manager: MultiplayerManager

@onready var address := $Address as LineEdit
@onready var host_button := $Host as Button
@onready var join_button := $Join as Button
@onready var start_button := $Start as Button
@onready var status := $Status as Label


func _ready() -> void:
	host_button.pressed.connect(multiplayer_manager.set_host)
	host_button.pressed.connect(func(): _set_status("Hosting..."))

	join_button.pressed.connect(func(): multiplayer_manager.set_client(address.text))
	start_button.pressed.connect(func():
			_set_status("Game started with %s players." % multiplayer_manager.player_count)
			multiplayer_manager.start_game_for_all()
	)


func _set_status(text = "") -> void:
	status.text = text
