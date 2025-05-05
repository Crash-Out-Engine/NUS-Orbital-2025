extends Node2D

@onready var player: Player = $"/root/Game/EntityContainer/Player"
@onready var player_camera: Camera2D = $"/root/Game/EntityContainer/Player/Camera2D"
@onready var parent := get_parent() as ChunkTileMap

@export var active := false

func _process(_delta: float) -> void:
	if active:
		queue_redraw()
	
func _draw() -> void:
	if active:
		var cam_center := player_camera.get_screen_center_position()
		var cam_size := (
			player_camera.get_viewport_rect() *
			player_camera.get_canvas_transform().affine_inverse()
			).size
		var start = cam_center - cam_size / 2
		var end = cam_center + cam_size / 2
		
		var chunk_coords_size := parent.chunk_size * parent.tile_set.tile_size
		var start_chunk := floor(start / Vector2(chunk_coords_size)) as Vector2i
		var end_chunk := ceil(end / Vector2(chunk_coords_size)) as Vector2i
		var chunk_rect := end_chunk - start_chunk
		for x in range(chunk_rect.x):
			var chunk_position = (start_chunk + Vector2i(x, 0)) * chunk_coords_size
			draw_line(chunk_position, chunk_position + Vector2i(0, chunk_coords_size.y) * chunk_rect, Color("#00FF00"))
		for y in range(chunk_rect.y):
			var chunk_position = (start_chunk + Vector2i(0, y)) * chunk_coords_size
			draw_line(chunk_position, chunk_position + Vector2i(chunk_coords_size.x, 0) * chunk_rect, Color("#00FF00"))
