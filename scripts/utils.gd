class_name Utils


static func assert_authority(node: Node) -> void:
	assert(node.is_multiplayer_authority(), "Node %s is not the authority here." % node.get_path())


static func assert_server(node: Node) -> void:
	assert(node.multiplayer.is_server(), "Node %s is not the server here." % node.get_path())


static func get_entity_bounds(entity: CollisionObject2D) -> Rect2:
	var bounds: Rect2 = Rect2()
	for owner in entity.get_shape_owners():
		if bounds == Rect2():
			bounds = entity.shape_owner_get_shape(owner, 0).get_rect()
		else:
			bounds = bounds.merge(entity.shape_owner_get_shape(owner, 0).get_rect())

	return bounds


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


static func get_rect_side_margin(rect: Rect2i, from: Vector2i, side: Side) -> int:
	match side:
		SIDE_LEFT:
			return from.x - rect.position.x
		SIDE_RIGHT:
			return rect.end.x - from.x - 1
		SIDE_TOP:
			return from.y - rect.position.y
		SIDE_BOTTOM:
			return rect.end.y - from.y - 1
		_:
			assert(false)
			return int()

static func offset_rect(rect: Rect2, point: Vector2) -> Rect2:
	return rect * Transform2D().translated(-point).translated(rect.get_center())