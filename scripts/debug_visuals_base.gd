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
	if Input.is_action_just_pressed("debug"):
		_debug_enabled = !_debug_enabled

	if _debug_enabled:
		show()
		queue_redraw()
	else:
		hide()
