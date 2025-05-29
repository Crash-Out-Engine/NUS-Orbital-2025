class_name ChunkTileMap
extends TileMapLayer

@export var noise: Noise
@export var curve: Curve
@export var tileset_dimensions: Vector2i
@export var zeroth_tile: Vector2i

var chunk_radius := 6
var chunk_size := Vector2i(8, 8)
var _loaded_chunks: Array[Vector2i] = []
var _prev_player_chunk_position: Vector2i = Vector2i.MIN

@onready var player: Player = $"/root/Game/EntityContainer/Player"


func _process(_delta: float) -> void:
	var player_chunk_position := floor(
			(local_to_map(player.position) / (scale as Vector2i)) /
			chunk_size) as Vector2i
	
	if player_chunk_position != _prev_player_chunk_position:
		load_chunks(player_chunk_position)
		unload_distant_chunks(player_chunk_position)
	
	_prev_player_chunk_position = player_chunk_position


func load_chunks(player_chunk_position: Vector2i) -> void:
	for x in range(-chunk_radius, chunk_radius + 1):
		for y in range(-chunk_radius, chunk_radius + 1):
			var chunk = Vector2i(x, y) + player_chunk_position
			if chunk not in _loaded_chunks:
				_generate_chunk(chunk)


func unload_distant_chunks(player_chunk_position: Vector2i) -> void:
	var unload_dist = (chunk_radius * 2) + 1
	
	for chunk in _loaded_chunks:
		var dist_to_player := player_chunk_position.distance_to(chunk)
		if dist_to_player > unload_dist:
			_clear_chunk(chunk)
		

func _generate_chunk(at_chunk: Vector2i) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var tile_coords = at_chunk * chunk_size + Vector2i(x, y)
				
			var noise_value = curve.sample(
					noise.get_noise_2d(tile_coords.x, tile_coords.y))
			
			var tile_value = floor((noise_value) * tileset_dimensions.x * tileset_dimensions.y) as int
			
			set_cell(tile_coords, 0, Vector2i(tile_value % tileset_dimensions.x + zeroth_tile.x, tile_value / tileset_dimensions.x + zeroth_tile.y))
			_loaded_chunks.append(at_chunk)


func _clear_chunk(at_chunk: Vector2i) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var tile_coords = at_chunk * chunk_size + Vector2i(x, y)
				
			set_cell(tile_coords)
			_loaded_chunks.erase(at_chunk) #should this be at this level of indentation?
