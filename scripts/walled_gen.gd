class_name WalledGen
extends StructureGenBase

const _BOUNDING_SIZE := Vector2i(100, 100)

@export var noise: Noise
@export var curve: Curve

var _chunk_size: Vector2i


func setup(_seed: int, chunk_size: Vector2i) -> void:
	_chunk_size = chunk_size
	noise.seed = _seed


func generate_chunk_points(chunk_pos: Vector2i) -> Array[StructureGenManager.StructureSpawnData]:
	const NUM_SAMPLES_TILL_REJECTION := 30
	var density := curve.sample(noise.get_noise_2dv(chunk_pos))
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s%s" % [chunk_pos, density]).hash()

	var region = Rect2i(
			chunk_pos * _chunk_size, _chunk_size)
	var cell_size := _BOUNDING_SIZE.length()
	var radius := cell_size * sqrt(2)
	var grid: Array[Array]

	for row_index in ceilf(region.size.y / cell_size):
		grid.append(Array())
		for col_index in ceilf(region.size.x / cell_size):
			grid[row_index].append(-1)

	var points: Array[Vector2i]
	var spawn_points: Array[Vector2i]

	var rand_x := rng.randi_range(region.position.x, region.end.x - 1)
	var rand_y := rng.randi_range(region.position.y, region.end.y - 1)
	spawn_points.push_front(Vector2i(rand_x, rand_y))

	while not spawn_points.is_empty():
		var spawn_index := rng.randi_range(0, spawn_points.size() - 1)
		var spawn_center := spawn_points[spawn_index]

		var candidate_accepted := false

		for i in NUM_SAMPLES_TILL_REJECTION:
			var angle := rng.randf() * 2 * PI
			var dir := Vector2.from_angle(angle)
			var candidate = spawn_center + (dir * rng.randf_range(radius, 2 * radius) as Vector2i)
			if _is_valid_point(candidate, region, cell_size, radius, points, grid):
				var row_index := int((candidate.y - region.position.y) / cell_size)
				var col_index := int((candidate.x - region.position.x) / cell_size)
				grid[row_index][col_index] = points.size()
				points.append(candidate)
				spawn_points.append(candidate)
				candidate_accepted = true
				break

		if not candidate_accepted:
			spawn_points.remove_at(spawn_index)

	seed(rng.randi())
	points.shuffle()
	points.resize(int(points.size() * density))

	var ret_array: Array[StructureGenManager.StructureSpawnData]
	for point in points:
		var start_side := rng.randi_range(0, 3) as Side
		var box_size = Vector2i(rng.randi_range(60, 100), rng.randi_range(60, 100)).snappedi(2)
		var width := rng.randi_range(10, 25)
		width -= width % 2
		for i in rng.randi_range(1, 3):
			var side := (start_side + i) % 4 as Side
			var position := point
			var size: Vector2i
			match side:
				SIDE_LEFT:
					position += Vector2i((width - box_size.x) / 2, width / 2)
					size = Vector2i(width, box_size.y - width)
				SIDE_TOP:
					position += Vector2i(width / 2, (box_size.y - width) / 2)
					size = Vector2i(box_size.x - width, width)
				SIDE_RIGHT:
					position += Vector2i((box_size.x - width) / 2, -width / 2)
					size = Vector2i(width, box_size.y - width)
				SIDE_BOTTOM:
					position += Vector2i(-width / 2, (width - box_size.y) / 2)
					size = Vector2i(box_size.x - width, width)
			var spawn_data := StructureGenManager.StructureSpawnData.new()
			spawn_data.entity_type_string = "Wall"
			spawn_data.position = position
			spawn_data.bounding_box = Utils.offset_rect(Rect2i(Vector2i.ZERO, size), position)
			var temp_data := {} # HACK: Prefer to use formal class object
			temp_data["position"] = position
			temp_data["size"] = size
			temp_data["HealthProp"] = var_to_bytes(
					{"value": size.x * size.y * 0.5, "min_value": 0.0, "max_value": INF})
			spawn_data.load_data = var_to_bytes(temp_data)

			ret_array.append(spawn_data)
	return ret_array


static func _is_valid_point(
		candidate: Vector2i,
		sample_region: Rect2i,
		cell_size: float,
		radius: float,
		points: Array[Vector2i],
		grid: Array[Array]) -> bool:
	if not sample_region.has_point(candidate):
		return false

	var candidate_pos := (candidate - sample_region.position) / cell_size as Vector2i

	for dx in range(-2, 3):
		for dy in range(-2, 3):
			var diff = Vector2i(dx, dy)
			var neighbour_pos = candidate_pos + diff
			if not (0 <= neighbour_pos.y
					and neighbour_pos.y < grid.size()
					and 0 <= neighbour_pos.x
					and neighbour_pos.x < grid.front().size()):
				continue

			var neighbour_index: int = grid[neighbour_pos.y][neighbour_pos.x]
			if neighbour_index == -1:
				continue

			var dist_squared := candidate.distance_squared_to(points[neighbour_index])
			if dist_squared < radius ** 2:
				return false

	return true
