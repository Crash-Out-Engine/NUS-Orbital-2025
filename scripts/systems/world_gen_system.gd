class_name WorldGenSystem
extends Node

const CHUNK_SIZE: Vector2i = Vector2i(128, 128)

@export var game: Game
@export var layers: Array[ChunkGeneratorBase]

@export_group("Settings")
@export_custom(PROPERTY_HINT_LINK, "suffix:") var load_chunk_radius: Vector2i
@export_custom(PROPERTY_HINT_LINK, "suffix:") var unload_chunk_radius: Vector2i

var world_seed: int
var player: Player
var active: bool

var _active_chunks_boundary: Rect2i = Rect2i()
var _rng := RandomNumberGenerator.new()
var _prev_player_chunk_pos: Vector2i = Vector2i.MIN


func _ready() -> void:
	assert(load_chunk_radius <= unload_chunk_radius,
			"Load radius should be smaller than or equal tosa unload radius.")

	active = false


func _process(_delta: float) -> void:
	if active:
		_check_refresh(player.global_position)


func setup() -> void:
	world_seed = game.get_seed()
	_rng.seed = world_seed
	player = game.get_local_player()

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
		# Left side
		var left_size = - (_active_chunks_boundary.position.x - player_chunk_pos.x)
		var left_ideal_size = clampi(left_size, load_chunk_radius.x, unload_chunk_radius.x)
		if left_size != left_ideal_size:
			_active_chunks_boundary = _active_chunks_boundary.grow_side(SIDE_LEFT,
					left_ideal_size - left_size)
			_handle_rect_chunks(
				Rect2i(
					Utils.get_rect_corner(_active_chunks_boundary, CORNER_TOP_LEFT),
					Vector2i(left_ideal_size - left_size, _active_chunks_boundary.size.y)
				)
			)

		# right side
		var right_size = _active_chunks_boundary.end.x - player_chunk_pos.x - 1
		var right_ideal_size = clampi(right_size, load_chunk_radius.x, unload_chunk_radius.x)
		if right_size != right_ideal_size:
			_handle_rect_chunks(
				Rect2i(
					Utils.get_rect_corner(_active_chunks_boundary, CORNER_TOP_RIGHT),
					Vector2i(right_ideal_size - right_size, _active_chunks_boundary.size.y)
				)
			)
			_active_chunks_boundary = _active_chunks_boundary.grow_side(SIDE_RIGHT,
					right_ideal_size - right_size)

		# top side
		var top_size = - (_active_chunks_boundary.position.y - player_chunk_pos.y)
		var top_ideal_size = clampi(top_size, load_chunk_radius.y, unload_chunk_radius.y)
		if top_size != top_ideal_size:
			_active_chunks_boundary = _active_chunks_boundary.grow_side(SIDE_TOP,
					top_ideal_size - top_size)
			_handle_rect_chunks(
				Rect2i(
					Utils.get_rect_corner(_active_chunks_boundary, CORNER_TOP_LEFT),
					Vector2i(_active_chunks_boundary.size.x, top_ideal_size - top_size)
				)
			)

		# bottom side
		var bottom_size = _active_chunks_boundary.end.y - player_chunk_pos.y - 1
		var bottom_ideal_size = clampi(bottom_size, load_chunk_radius.y, unload_chunk_radius.y)
		if bottom_size != bottom_ideal_size:
			_handle_rect_chunks(
				Rect2i(
					Utils.get_rect_corner(_active_chunks_boundary, CORNER_BOTTOM_LEFT),
					Vector2i(_active_chunks_boundary.size.x, bottom_ideal_size - bottom_size)
				)
			)
			_active_chunks_boundary = _active_chunks_boundary.grow_side(SIDE_BOTTOM,
					bottom_ideal_size - bottom_size)


func _handle_rect_chunks(rect: Rect2i) -> void:
	match rect.get_area():
		0:
			return
		var pos when pos > 0:
			_load_rect_chunks(rect.abs())
		var neg when neg < 0:
			_unload_rect_chunks(rect.abs())


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
