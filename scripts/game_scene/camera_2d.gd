extends Camera2D

## The proportion of peeking relative to mouse position.
##
## If [code]PEEK_FACTOR = 0.2[/code], for every unit distance the mouse moves
## left of screen center, the _player camera peeks an additional 0.2 unit
## distance to the left and 0.2 unit distance less to the right.
const PEEK_FACTOR = 0.5

## The proportion of maximum peekable distance to viewport size.
##
## If [code]MAX_RECT_PROPORTION = 1.0[/code], then the maximum peekable distance
## will be such that the _player lies right at the border of the viewport.
##
## Note that if this value is higher than [member PEEK_FACTOR], then the _player
## will only hit the offset limit when the cursor is somewhere outside the
## viewport.
const MAX_RECT_PROPORTION = 0.5


var _max_offset_rect: Vector2
var _player: Player


func _ready() -> void:
	get_tree().get_root().size_changed.connect(_resize)
	_resize()


func _process(_delta: float) -> void:
	var desired_offset = (get_local_mouse_position()) * PEEK_FACTOR
	desired_offset = desired_offset.clamp(-_max_offset_rect / 2, _max_offset_rect / 2)
	global_position = _player.global_position + desired_offset


func setup(player: Player) -> void:
	_player = player


func _resize() -> void:
	var cam_size := (
			get_viewport_rect() *
			get_canvas_transform().affine_inverse()
			).size
	_max_offset_rect = cam_size * MAX_RECT_PROPORTION
