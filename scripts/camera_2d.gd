extends Camera2D

const ZOOM_FACTOR: float = sqrt(2.0)

const SMOOTHING_FACTOR: float = 0.9

var _zoom_power: float = 0.0
var _zooming: float = 0.0

func _physics_process(_delta: float) -> void:
	if _zoom_power + _zooming < 1.5 and Input.is_action_just_released("zoom in"):
		_zooming += 1.0
	if -6.5 < _zoom_power + _zooming and Input.is_action_just_released("zoom out"):
		_zooming -= 1.0
		
	_zoom_power += lerpf(0, _zooming, 1.0 - SMOOTHING_FACTOR)
	_zooming = lerpf(0, _zooming, SMOOTHING_FACTOR)
	zoom = Vector2.ONE * ZOOM_FACTOR ** _zoom_power
