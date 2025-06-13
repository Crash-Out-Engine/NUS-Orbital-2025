class_name TileMapGenerator
extends ChunkGeneratorBase

@export var noise: Noise
@export var curve: Curve
@export var tile_map_layer: TileMapLayer
@export var tileset_dimensions: Vector2i
@export var zeroth_tile: Vector2i

var _chunk_size: Vector2i


func setup(_seed: int, chunk_size: Vector2i) -> void:
	assert(chunk_size % tile_map_layer.tile_set.tile_size == Vector2i.ZERO,
			"Chunk size should be a multiple of tile size.")

	noise.seed = _seed

	var tile_chunk_size := chunk_size / tile_map_layer.tile_set.tile_size
	_chunk_size = tile_chunk_size


func generate_chunk(chunk_pos: Vector2i) -> void:
	assert(_chunk_size != Vector2i.ZERO)

	for x in range(_chunk_size.x):
		for y in range(_chunk_size.y):
			var tile_coords = chunk_pos * _chunk_size + Vector2i(x, y)

			var noise_value = curve.sample(
					noise.get_noise_2d(tile_coords.x, tile_coords.y))

			var tile_value = floor((noise_value) * tileset_dimensions.x * tileset_dimensions.y) as int

			var atlas_coords := Vector2i(
					tile_value % tileset_dimensions.x + zeroth_tile.x,
					tile_value / tileset_dimensions.x + zeroth_tile.y)
			tile_map_layer.set_cell(tile_coords, 0, atlas_coords)


func clear_chunk(chunk_pos: Vector2i) -> void:
	assert(_chunk_size != Vector2i.ZERO)

	for x in range(_chunk_size.x):
		for y in range(_chunk_size.y):
			var tile_coords = chunk_pos * _chunk_size + Vector2i(x, y)

			tile_map_layer.set_cell(tile_coords)
