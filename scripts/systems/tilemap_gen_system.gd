class_name TilemapGenSystem
extends Node

const CHUNK_SIZE: Vector2i = Vector2i(128, 128)

@export var layers: Array[ChunkGeneratorBase]

@export_group("Settings")
@export_custom(PROPERTY_HINT_LINK, "suffix: chunks") var load_chunk_radius: Vector2i
@export_custom(PROPERTY_HINT_LINK, "suffix: chunks") var unload_chunk_radius: Vector2i

var active: bool

var _player: Player
var _active_chunks_boundary: Rect2i = Rect2i()
var _rng := RandomNumberGenerator.new()
var _prev_player_chunk_pos: Vector2i = Vector2i.MIN


func _ready() -> void:
	assert(load_chunk_radius <= unload_chunk_radius,
			"Load radius should be smaller than or equal tosa unload radius.")

	active = false


func _process(_delta: float) -> void:
	if active:
		_check_refresh(_player.global_position)


func setup(game_seed: int, local_player: Player) -> void:
	_rng.seed = game_seed
	_player = local_player

	for layer in layers:
		layer.setup(_rng.randi(), CHUNK_SIZE)

	active = true


func _check_refresh(global_pos: Vector2) -> void:
	var player_chunk_pos := floor(global_pos / (CHUNK_SIZE as Vector2)) as Vector2i

	if player_chunk_pos != _prev_player_chunk_pos:
		_refresh_chunks(player_chunk_pos)

	_prev_player_chunk_pos = player_chunk_pos


func _refresh_chunks(player_chunk_pos: Vector2i) -> void:
	if !_active_chunks_boundary.has_area():
		_active_chunks_boundary.position = Vector2i(
				player_chunk_pos.x - load_chunk_radius.x,
				player_chunk_pos.y - load_chunk_radius.y)
		_active_chunks_boundary.end = Vector2i(
				player_chunk_pos.x + load_chunk_radius.x + 1,
				player_chunk_pos.y + load_chunk_radius.y + 1)

		_load_rect_chunks(_active_chunks_boundary)

	else:
		for side in 4:
			var size := _get_rect_side_margin(_active_chunks_boundary, player_chunk_pos, side)
			var ideal_size := clampi(size, load_chunk_radius[side % 2], unload_chunk_radius[side % 2])
			var diff := ideal_size - size
			if diff != 0:
				var diff_rect := Rect2i(
						_get_rect_corner(_active_chunks_boundary, side as Corner), Vector2i.ZERO)
				diff_rect = diff_rect\
						.grow_side((side + 3) % 4, _active_chunks_boundary.size[(side + 3) % 2])\
						.abs()\
						.grow_side(side, diff)
				if diff_rect.get_area() > 0:
					_load_rect_chunks(diff_rect.abs())
				elif diff_rect.get_area() < 0:
					_unload_rect_chunks(diff_rect.abs())
				_active_chunks_boundary = _active_chunks_boundary.grow_side(side, diff)


func _load_rect_chunks(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			for layer in layers:
				var chunk_pos := Vector2i(x, y)
				layer.generate_chunk(chunk_pos)


func _unload_rect_chunks(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			for layer in layers:
				var chunk_pos := Vector2i(x, y)
				layer.clear_chunk(chunk_pos)


static func _get_rect_corner(rect: Rect2i, corner: Corner) -> Vector2i:
	match corner:
		CORNER_TOP_LEFT:
			return rect.position
		CORNER_TOP_RIGHT:
			return Vector2i(rect.end.x, rect.position.y)
		CORNER_BOTTOM_RIGHT:
			return rect.end
		CORNER_BOTTOM_LEFT:
			return Vector2i(rect.position.x, rect.end.y)
		_:
			assert(false)
			return Vector2i()


static func _get_rect_side_margin(rect: Rect2i, from: Vector2i, side: Side) -> int:
	match side:
		SIDE_LEFT:
			return from.x - rect.position.x
		SIDE_RIGHT:
			return rect.end.x - from.x - 1
		SIDE_TOP:
			return from.y - rect.position.y
		SIDE_BOTTOM:
			return rect.end.y - from.y - 1
		_:
			assert(false)
			return int()
