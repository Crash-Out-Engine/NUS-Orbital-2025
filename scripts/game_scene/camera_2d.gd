extends Camera2D

const ZOOM_FACTOR: float = sqrt(2.0)
const SMOOTHING_FACTOR: float = 0.9

const PEAK_FACTOR = 0.15

var _zoom_power: float = 0.0
var _zooming: float = 0.0

@onready var player := get_parent() as Player

func _process(_delta: float) -> void:
	if _zoom_power + _zooming < 0.5 and Input.is_action_just_released("zoom in"):
		_zooming += 1.0
	if -1 < _zoom_power + _zooming and Input.is_action_just_released("zoom out"):
		_zooming -= 1.0
		
	_zoom_power += lerpf(0, _zooming, 1.0 - SMOOTHING_FACTOR)
	_zooming = lerpf(0, _zooming, SMOOTHING_FACTOR)
	zoom = Vector2.ONE * ZOOM_FACTOR ** _zoom_power
	
	
	offset.x = PEAK_FACTOR * (get_global_mouse_position().x - player.global_position.x)
	offset.y = PEAK_FACTOR * (get_global_mouse_position().y - player.global_position.y)
	
