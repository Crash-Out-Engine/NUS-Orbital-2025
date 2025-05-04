extends TileMapLayer

@export var noise_height_texture: NoiseTexture2D

@onready var player: Player = $"/root/Game/EntityContainer/Player"

var noise: Noise
var width := 64
var height := 64

var loaded_chunks: Array[Vector2i] = []

func _ready() -> void:
	noise = noise_height_texture.noise
	
func _process(delta: float) -> void:
	var player_tile_position := local_to_map(player.position)
	
	generate_chunk(player_tile_position)
	unload_distant_chunks(player_tile_position)

func generate_chunk(at: Vector2i):
	for x in range(width):
		for y in range(height):
			var tile_coords = Vector2i(
				at.x - (width / 2) + x,
				at.y - (height / 2) + y)
				
			var noise_value = noise.get_noise_2d(
				tile_coords.x,
				tile_coords.y)
			
			var tile_value = floor((noise_value + 1) * 2) as int
				
			set_cell(tile_coords, 0, Vector2i(tile_value / 2, tile_value % 2))
			
			if at not in loaded_chunks:
				loaded_chunks.append(at)

func unload_distant_chunks(player_tile_position: Vector2i):
	var unload_dist = (width * 2) + 1
	
	for chunk in loaded_chunks:
		var dist_to_player := player_tile_position.distance_to(chunk)
		if dist_to_player > unload_dist:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)
		

func clear_chunk(at: Vector2):
	for x in range(width):
		for y in range(height):
			var tile_coords = Vector2i(
				at.x - (width / 2) + x,
				at.y - (height / 2) + y)
				
			set_cell(tile_coords)
