class_name DebugVisualsBase
extends Node2D
## An abstract base class for debugging visuals that involve manual drawing.
##
## Classes that inherit this class should override [method CanvasItem._draw]
## with their custom draw instructions.
## This class queues redraws and handles toggling through the "debug" action.

var _debug_enabled: bool = false


func _init() -> void:
	assert(get_class() != "DebugVisualsBase",
			"DebugVisualsBase is an abstract class and cannot be instantiated.")


func _ready() -> void:
	z_index = 100


func _process(_delta: float) -> void:
	if _debug_enabled:
		show()
		queue_redraw()
	else:
		hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_debug_enabled = !_debug_enabled
