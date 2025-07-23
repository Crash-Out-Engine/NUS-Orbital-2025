class_name StructureGenManager
extends Node

const CHUNK_SIZE: Vector2i = Vector2i(512, 512)

@export var layers: Array[StructureGenBase]

@export_group("Settings")
@export_custom(PROPERTY_HINT_LINK, "suffix: chunks") var load_chunk_radius: Vector2i
@export_custom(PROPERTY_HINT_LINK, "suffix: chunks") var unload_chunk_radius: Vector2i

var active: bool = false

var _entity_manager: EntityManager
var _players: Array[Player]
var _active_chunks_boundary: Rect2i = Rect2i()
var _rng := RandomNumberGenerator.new()
var _prev_players_chunk_pos: Dictionary[Player, Vector2i]

var _chunks_load_count: Dictionary[Vector2i, int]
## Structures in loaded chunks.
var _loaded_structures: Dictionary[Vector2i, Array]
## Saved data of structures when unloaded.
var _chunks_data: Dictionary[Vector2i, PackedByteArray]


func _ready() -> void:
	assert(load_chunk_radius <= unload_chunk_radius,
			"Load radius should be smaller than or equal to unload radius.")


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if active:
		for player in _players:
			_check_refresh(player)


func setup(game_seed: int, entity_manager: EntityManager) -> void:
	_rng.seed = game_seed
	_entity_manager = entity_manager

	for layer in layers:
		layer.setup(_rng.randi(), CHUNK_SIZE)

	for player in _players:
		_check_refresh(player, true)

	active = true


func register_player(player: Player) -> void:
	_players.append(player)


func _check_refresh(player: Player, force: bool = false) -> void:
	var player_chunk_pos := floor(player.position / (CHUNK_SIZE as Vector2)) as Vector2i

	if force or player_chunk_pos != _prev_players_chunk_pos[player]:
		_refresh_chunks(player_chunk_pos, force)

	_prev_players_chunk_pos[player] = player_chunk_pos


func _refresh_chunks(player_chunk_pos: Vector2i, blocking: bool = false) -> void:
	if !_active_chunks_boundary.has_area():
		_active_chunks_boundary.position = Vector2i(
				player_chunk_pos.x - load_chunk_radius.x,
				player_chunk_pos.y - load_chunk_radius.y)
		_active_chunks_boundary.end = Vector2i(
				player_chunk_pos.x + load_chunk_radius.x + 1,
				player_chunk_pos.y + load_chunk_radius.y + 1)

		if blocking:
			_load_rect_chunks(_active_chunks_boundary)
		else:
			WorkerThreadPool.add_task(_load_rect_chunks.bind(_active_chunks_boundary))

	else:
		for side in 4:
			var size := Utils.get_rect_side_margin(_active_chunks_boundary, player_chunk_pos, side)
			var ideal_size := clampi(size, load_chunk_radius[side % 2], unload_chunk_radius[side % 2])
			var diff := ideal_size - size
			if diff != 0:
				var diff_rect := Rect2i(
						Utils.get_rect_corner(_active_chunks_boundary, side as Corner), Vector2i.ZERO)
				diff_rect = diff_rect \
						.grow_side((side + 3) % 4, _active_chunks_boundary.size[(side + 3) % 2]) \
						.abs() \
						.grow_side(side, diff)
				if diff_rect.get_area() > 0:
					if blocking:
						_load_rect_chunks(diff_rect.abs())
					else:
						WorkerThreadPool.add_task(_load_rect_chunks.bind(diff_rect.abs()))
				elif diff_rect.get_area() < 0:
					_unload_rect_chunks(diff_rect.abs())
				_active_chunks_boundary = _active_chunks_boundary.grow_side(side, diff)


func _load_rect_chunks(rect: Rect2i) -> void:
	var initial_rect := rect.grow(2)
	var first_pass_rect := rect.grow(1)
	var second_pass_rect := rect

	# Dictionary[Vector2i, Array[StructureSpawnData]]
	var spawn_data: Dictionary[Vector2i, Array]
	# Dictionary[Vector2i, Array[StructureSpawnData]]
	var first_pass_accum: Dictionary[Vector2i, Array]

	for layer in layers:
		var initial_points: Dictionary[Vector2i, Array]
		var first_pass_points: Dictionary[Vector2i, Array]

		for x in range(initial_rect.position.x, initial_rect.end.x):
			for y in range(initial_rect.position.y, initial_rect.end.y):
				var chunk_pos := Vector2i(x, y)
				initial_points.set(chunk_pos, layer.generate_chunk_points(chunk_pos))

		# First pass: with neighbours
		for x in range(first_pass_rect.position.x, first_pass_rect.end.x):
			for y in range(first_pass_rect.position.y, first_pass_rect.end.y):
				var chunk_pos := Vector2i(x, y)
				var chunk_points := initial_points[chunk_pos]

				var neighbour_points: Array[StructureSpawnData]
				for i in 8:
					var angle := (2 * PI) * (i / 8.0)
					var diff := Vector2.from_angle(angle).snappedf(1.0) as Vector2i
					var neighbour_chunk_pos = chunk_pos + diff
					neighbour_points.append_array(initial_points[neighbour_chunk_pos])

				first_pass_points.set(chunk_pos, first_pass_cull_points(chunk_points, neighbour_points))

		# Second pass: with previous layers

		for x in range(second_pass_rect.position.x, second_pass_rect.end.x):
			for y in range(second_pass_rect.position.y, second_pass_rect.end.y):
				var chunk_pos := Vector2i(x, y)
				var chunk_points := first_pass_points[chunk_pos]

				var neighbour_points: Array[StructureSpawnData]
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						var diff := Vector2i(dx, dy)
						var neighbour_chunk_pos = chunk_pos + diff
						neighbour_points.append_array(first_pass_accum.get(neighbour_chunk_pos, []))

				spawn_data.get_or_add(chunk_pos, []).append_array(
						second_pass_cull_points(chunk_points, neighbour_points))

		# Accumulate first pass points
		for x in range(first_pass_rect.position.x, first_pass_rect.end.x):
			for y in range(first_pass_rect.position.y, first_pass_rect.end.y):
				var chunk_pos := Vector2i(x, y)
				first_pass_accum.get_or_add(chunk_pos, []).append_array(first_pass_points[chunk_pos])

	for chunk_pos in spawn_data:
		var chunk_spawn: Array[StructureSpawnData]
		chunk_spawn.assign(spawn_data[chunk_pos])
		call_deferred("_spawn_chunk", chunk_pos, chunk_spawn)


func _unload_rect_chunks(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var chunk_pos := Vector2i(x, y)
			_clear_chunk(chunk_pos)


func _spawn_chunk(chunk_pos: Vector2i, chunk_data: Array[StructureSpawnData]) -> void:
	_chunks_load_count.set(chunk_pos, _chunks_load_count.get(chunk_pos, 0) + 1)

	if _chunks_load_count[chunk_pos] != 1:
		return

	var structures: Array[Node2D]

	if chunk_pos in _chunks_data:
		chunk_data.assign(bytes_to_var(_chunks_data[chunk_pos])\
				.map(func(data): return StructureSpawnData.from(data)))

	for spawn_data: StructureSpawnData in chunk_data:
		var structure = _entity_manager.server_load_entity(
				spawn_data.entity_type_string, spawn_data.load_data, self)
		structures.append(structure)

	_loaded_structures.set(chunk_pos, structures)


func _clear_chunk(chunk_pos: Vector2i) -> void:
	_chunks_load_count[chunk_pos] -= 1

	if _chunks_load_count[chunk_pos] == 0:
		var spawn_data := _loaded_structures[chunk_pos]\
				.filter(func(entity: Node2D): return entity != null)\
				.map(func(entity: Node2D): return StructureSpawnData.from_entity(entity).save())
		var data := var_to_bytes(spawn_data)
		_chunks_data.set(chunk_pos, data)

		for structure in _loaded_structures[chunk_pos]:
			if structure != null:
				_entity_manager.server_remove_entity(structure)
		_loaded_structures.erase(chunk_pos)


static func first_pass_cull_points(
		points: Array[StructureSpawnData],
		neighbour_points: Array[StructureSpawnData]) -> Array[StructureSpawnData]:
	return points.filter(func(point: StructureSpawnData):
			for other in neighbour_points:
				if point.bounding_box.intersects(other.bounding_box):
					if point.to_string().hash() <= other.to_string().hash():
						return false
			return true
	)


static func second_pass_cull_points(
		points: Array[StructureSpawnData],
		others: Array[StructureSpawnData],
		) -> Array[StructureSpawnData]:
	return points.filter(
			func(point: StructureSpawnData):
				return not others.any(
						func(other: StructureSpawnData):
							return point.bounding_box.intersects(other.bounding_box)
				)
	)


class StructureSpawnData:
	var entity_type_string: String:
		set(value):
			if entity_type_string == String():
				entity_type_string = value
	var load_data: PackedByteArray:
		set(value):
			if load_data == PackedByteArray():
				load_data = value
	var position: Vector2:
		set(value):
			if position == Vector2():
				position = value
	var bounding_box: Rect2:
		set(value):
			if bounding_box == Rect2():
				bounding_box = value


	static func from_entity(entity: Node2D) -> StructureSpawnData:
		var spawn_data := new()
		spawn_data.entity_type_string = entity.get_script().get_global_name()
		spawn_data.load_data = entity.save_scene()
		spawn_data.position = entity.position
		spawn_data.bounding_box = Utils.get_entity_bounds(entity)
		return spawn_data


	func intersects(other: StructureSpawnData) -> bool:
		return bounding_box.intersects(other.bounding_box)


	##region Save/load

	static func from(data: PackedByteArray) -> StructureSpawnData:
		var dict := bytes_to_var(data) as Dictionary
		var spawn_data := new()
		spawn_data.entity_type_string = dict["entity_type_string"]
		spawn_data.load_data = dict["load_data"]
		spawn_data.position = dict["position"]
		spawn_data.bounding_box = dict["bounding_box"]
		return spawn_data


	func save() -> PackedByteArray:
		var dict := {}
		dict["entity_type_string"] = entity_type_string
		dict["load_data"] = load_data
		dict["position"] = position
		dict["bounding_box"] = bounding_box
		return var_to_bytes(dict)

	##endregion


	func _to_string() -> String:
		return ("StructureSpawnData { %s, %s, %s, %s }"
				% [
					"entity_type_string: %s" % entity_type_string,
					"load_data: %s" % load_data.hex_encode(),
					"position: %s" % position,
					"bounding_box: %s" % bounding_box,
				])
