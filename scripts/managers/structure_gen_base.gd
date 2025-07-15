class_name StructureGenBase
extends Node


func _init() -> void:
	assert(get_class() != "ChunkGeneratorBase",
		"ChunkGeneratorBase is an abstract base class and cannot be instantiated.")


func setup(_seed: int, _chunk_size: Vector2i) -> void:
	assert(false, "This method should be overridden.")


## Implementation should guarantee that points are culled such that each of them do not intersect
## one another.
func generate_chunk_points(_chunk_pos: Vector2i) -> Array[StructureGenManager.StructureSpawnData]:
	assert(false, "This method should be overridden.")
	return Array()
