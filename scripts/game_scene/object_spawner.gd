extends Node2D

var _FAULT_SCENE = preload("res://scenes/fault.tscn") #HACK: Objects in the map should be collected in a group

@export var noise: Noise
@export var curve: Curve
@export var entity_container: Node

var chunk_radius := 3
var chunk_size := Vector2i(8.0, 8.0)
var grid_size := Vector2i(32.0, 32.0)
var _loaded_chunks: Array[Vector2i] = []
var _prev_player_chunk_position: Vector2i = Vector2i.MIN

@onready var player := $"../EntityContainer/Player" as Player

var rng = RandomNumberGenerator.new()

func _ready():
	noise.offset.x = randf_range(-1000, 1000)
	noise.offset.y = randf_range(-1000, 1000)

func _process(_delta: float) -> void:
	var player_chunk_position := floor(player.global_position as Vector2i / grid_size / chunk_size) as Vector2i
	
	if player_chunk_position != _prev_player_chunk_position:
		load_chunks(player_chunk_position)
		unload_distant_chunks(player_chunk_position)
	
	_prev_player_chunk_position = player_chunk_position

func create_fault(pos: Vector2) -> void: #HACK: world generation should be general, honestly this whole script is a hack
	var fault = _FAULT_SCENE.instantiate()
	fault.global_position = pos
	fault.set_power_output(get_parent())
	get_parent().add_entity(fault)

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
					noise.get_noise_2d(tile_coords.x, tile_coords.y)) #HACK: generation should not be completely random and be controlled such that faults are spread evenly
			
			if noise_value > 0.99995: #HACK
				create_fault(tile_coords * grid_size)
			
	_loaded_chunks.append(at_chunk)


func _clear_chunk(at_chunk: Vector2i) -> void:
	var min_point = at_chunk * chunk_size * grid_size
	var max_point = (at_chunk * chunk_size + chunk_size) * grid_size
	var to_remove = entity_container.get_children().filter(func(obj): return obj is Fault).filter(func(fault): return fault_check(fault, min_point, max_point))
	print("min:" + str(min_point))
	print("max:" + str(max_point))
	for fault in to_remove:
		print("fault:" + str(fault.global_position))
		fault.queue_free()
	_loaded_chunks.erase(at_chunk)

func fault_check(fault: Fault, min_point: Vector2, max_point: Vector2) -> bool:
	return min_point.x <= fault.global_position.x and fault.global_position.x < max_point.x and min_point.y <= fault.global_position.y and fault.global_position.y < max_point.y
