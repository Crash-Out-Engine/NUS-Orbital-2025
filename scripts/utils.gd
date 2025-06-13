class_name Utils

static func get_rect_corner(rect: Rect2i, corner: Corner) -> Vector2i:
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
