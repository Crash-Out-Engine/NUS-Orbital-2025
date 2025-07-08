class_name LifetimeComp
extends Node

@export var timeout_prop: TimeoutProp
## If true, timer will start initially and on [TimeoutProp]'s
## [signal PropertyBase.changed] signal.
@export var autostart: bool = true
## If true, this component will help the entity despawn whenever
## [signal Timer.timeout] is triggered.
@export var autodespawn: bool = true

var _timer := Timer.new()

@onready var _entity = $"../.."

func _ready() -> void:
	if not is_multiplayer_authority():
		return

	_timer.one_shot = true
	add_child(_timer)
	if autostart:
		timeout_prop.changed.connect(func(_from, to): _timer.start(to))
		_timer.start(timeout_prop.value)
	if autodespawn:
		_timer.timeout.connect(func(): _entity.get_parent().server_remove_entity(_entity))
