class_name Sprite2DRect
extends TextureRect

@export var FrameMargin: Vector2
@export var FrameSize: Vector2

@export_group("Animation")
@export var HFrames: int = 1
@export var VFrames: int = 1
@export var Frame: int = 0 :
	set(value):
		Frame = value
		Frame_Coords = Vector2i(Frame % HFrames, Frame / HFrames)
@export var Frame_Coords: Vector2i = Vector2i(0, 0):
	set(value):
		Frame_Coords = value
		texture.region = Rect2(
			FrameMargin.x + (FrameMargin.x * 2 + FrameSize.x) * Frame_Coords.x,
			FrameMargin.y + (FrameMargin.y * 2 + FrameSize.y) * Frame_Coords.y,
			FrameSize.x,
			FrameSize.y)
