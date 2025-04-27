extends Camera2D

const ZOOM_FACTOR: float = 1.2

const SMOOTHING_FACTOR: float = 0.9

var _zooming: float = 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("zoom in"):
		_zooming += 1.0
	if Input.is_action_just_released("zoom out"):
		_zooming -= 1.0
		
	zoom *= ZOOM_FACTOR ** (lerpf(0, _zooming, 1.0 - SMOOTHING_FACTOR))
	_zooming = lerpf(0, _zooming, SMOOTHING_FACTOR)
