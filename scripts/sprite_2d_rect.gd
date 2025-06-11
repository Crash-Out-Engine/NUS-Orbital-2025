class_name Sprite2DRect
extends TextureRect

@export var frame_margin: Vector2
@export var frame_size: Vector2

@export_group("Animation")
@export var h_frames: int = 1
@export var v_frames: int = 1
@export var frame: int = 0 :
	set(value):
		frame = value
		frame_coords = Vector2i(frame % h_frames, frame / h_frames)
@export var frame_coords: Vector2i = Vector2i(0, 0):
	set(value):
		frame_coords = value
		texture.region = Rect2(
			frame_margin.x + (frame_margin.x * 2 + frame_size.x) * frame_coords.x,
			frame_margin.y + (frame_margin.y * 2 + frame_size.y) * frame_coords.y,
			frame_size.x,
			frame_size.y)
