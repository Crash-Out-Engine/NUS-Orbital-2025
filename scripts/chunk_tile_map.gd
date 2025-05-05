class_name ChunkTileMap extends TileMapLayer

@export var noise: Noise
@export var curve: Curve

@onready var player: Player = $"/root/Game/EntityContainer/Player"

var chunk_radius := 4
var chunk_size := Vector2i(16, 16)

var loaded_chunks: Array[Vector2i] = []

var _prev_player_chunk_position: Vector2i = Vector2i.MIN
func _process(_delta: float) -> void:
	var player_chunk_position := floor(
		(local_to_map(player.position) as Vector2) /
		(chunk_size as Vector2)) as Vector2i
	
	if player_chunk_position != _prev_player_chunk_position:
		load_chunks(player_chunk_position)
		unload_distant_chunks(player_chunk_position)
	
	_prev_player_chunk_position = player_chunk_position

func generate_chunk(at_chunk: Vector2i) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var tile_coords = at_chunk * chunk_size + Vector2i(x, y)
				
			var noise_value = curve.sample(
				noise.get_noise_2d(
					tile_coords.x,
					tile_coords.y
					)
				)
			
			var tile_value = floor((noise_value) * 6) as int
				
			set_cell(tile_coords, 0, Vector2i(tile_value % 3, tile_value / 3))
			loaded_chunks.append(at_chunk)

func load_chunks(player_chunk_position: Vector2i) -> void:
	for x in range(-chunk_radius, chunk_radius + 1):
		for y in range(-chunk_radius, chunk_radius + 1):
			var chunk = Vector2i(x, y) + player_chunk_position
			if chunk not in loaded_chunks:
				generate_chunk(chunk)

func unload_distant_chunks(player_chunk_position: Vector2i) -> void:
	var unload_dist = (chunk_radius * 2) + 1
	
	for chunk in loaded_chunks:
		var dist_to_player := player_chunk_position.distance_to(chunk)
		if dist_to_player > unload_dist:
			clear_chunk(chunk)
		

func clear_chunk(at_chunk: Vector2i) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var tile_coords = at_chunk * chunk_size + Vector2i(x, y)
				
			set_cell(tile_coords)
			loaded_chunks.erase(at_chunk)
