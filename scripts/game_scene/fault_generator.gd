class_name FaultGenerator
extends ChunkGeneratorBase

enum SaveResult {
	SAVED,
	OVERWRITTEN,
}
enum LoadResult {
	LOADED,
	NOT_FOUND,
}

const _FAULT_SCENE = preload("res://scenes/fault.tscn")

@export var noise: Noise
@export var curve: Curve
@export var entity_manager: Node

var _grid_chunk_size: Vector2i
var _grid_size := Vector2i(32.0, 32.0)
## Server player count in loaded chunks.
var _chunk_player_count: Dictionary[Vector2i, int] = {}
## Server faults in loaded chunks.
var _chunk_faults: Dictionary[Vector2i, Array] = {}
## Server saved chunks.
var _chunk_data: Dictionary[Vector2i, PackedByteArray] = {}


func setup(_seed: int, chunk_size: Vector2i) -> void:
	assert(chunk_size % _grid_size == Vector2i.ZERO,
			"Chunk size should be a multiple of grid size.")

	_grid_chunk_size = chunk_size / _grid_size

	noise.seed = _seed


func generate_chunk(chunk_pos: Vector2i) -> void:
	_generate_chunk.rpc_id(get_multiplayer_authority(), chunk_pos)


func clear_chunk(chunk_pos: Vector2i) -> void:
	_clear_chunk.rpc_id(get_multiplayer_authority(), chunk_pos)


@rpc("any_peer", "call_local", "reliable")
func _generate_chunk(chunk_pos: Vector2i) -> void:
	if is_multiplayer_authority():
		if _chunk_player_count.get(chunk_pos, 0) == 0:
			_load_chunk(chunk_pos)

		_chunk_player_count.set(chunk_pos, _chunk_player_count.get(chunk_pos, 0) + 1)


@rpc("any_peer", "call_local", "reliable")
func _clear_chunk(chunk_pos: Vector2i) -> void:
	if not is_multiplayer_authority():
		return

	_chunk_player_count[chunk_pos] -= 1

	if _chunk_player_count[chunk_pos] == 0:
		_save_chunk(chunk_pos)
		_free_chunk(chunk_pos)


func _save_chunk(chunk_pos: Vector2i) -> void:
	if chunk_pos not in _chunk_faults:
		assert(false, "%s" % chunk_pos)
	var chunk_fault_data := _chunk_faults[chunk_pos]\
			.filter(func(fault): return fault != null)\
			.map(func(fault: Fault) -> PackedByteArray: return fault.save_scene())
	var byte_data := var_to_bytes(chunk_fault_data)
	_chunk_data[chunk_pos] = byte_data


func _free_chunk(chunk_pos: Vector2i) -> void:
	for fault: Fault in _chunk_faults[chunk_pos].filter(func(fault): return fault != null):
		entity_manager.server_remove_entity(fault)
	_chunk_faults.erase(chunk_pos)


func _load_chunk(chunk_pos: Vector2i) -> void:
	var faults: Array[Fault] = []
	if chunk_pos in _chunk_data:
		var chunk_fault_data := bytes_to_var(_chunk_data[chunk_pos]) as Array
		for fault_data: PackedByteArray in chunk_fault_data:
			var fault = _create_fault()
			fault.load_saved_scene(fault_data)
			faults.append(fault)
	else:
		for x in range(_grid_chunk_size.x):
			for y in range(_grid_chunk_size.y):
				var tile_coords = chunk_pos * _grid_chunk_size + Vector2i(x, y)

				var noise_value = curve.sample(
						noise.get_noise_2d(tile_coords.x, tile_coords.y))

				if noise_value == 1:
					var fault = _create_fault()
					fault.global_position = tile_coords * _grid_size
					faults.append(fault)

	_chunk_faults.set(chunk_pos, faults)


func _create_fault() -> Fault:
	if is_multiplayer_authority():
		var fault := _FAULT_SCENE.instantiate()
		entity_manager.server_add_entity(fault, self)

		return fault

	return null
