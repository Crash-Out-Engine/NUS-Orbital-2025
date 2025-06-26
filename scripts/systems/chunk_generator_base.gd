class_name ChunkGeneratorBase
extends Node


func _init() -> void:
  assert(get_class() != "ChunkGeneratorBase",
	  "ChunkGeneratorBase is an abstract base class and cannot be instantiated.")


func setup(_seed: int, _chunk_size: Vector2i) -> void:
  assert(false, "This method should be overridden.")


func generate_chunk(_chunk_pos: Vector2i) -> void:
  assert(false, "This method should be overridden.")


func clear_chunk(_chunk_pos: Vector2i) -> void:
  assert(false, "This method should be overridden.")
