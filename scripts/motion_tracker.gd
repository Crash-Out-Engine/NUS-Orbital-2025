class_name MotionTracker
extends Node
## Utility node for tracking [class Node2D]'s motion.
##
## Since this class's initializer adds itself as a child to the tracked entity
## and uses the entity's [member Node.process_physics_priority], it will run
## after the entity's motion, ensuring the least latency.

var position: Vector2
var velocity: Vector2
var acceleration: Vector2
var _entity: Node2D
var _first_frame: bool = true
var _second_frame: bool = true


## Attaches a [class MotionTracker] node to an entity.
static func attach_to(entity: Node2D) -> MotionTracker:
	return new(entity)


func _init(entity: Node2D) -> void:
	process_physics_priority = entity.process_physics_priority
	entity.add_child(self)
	_entity = entity


func _ready() -> void:
	self.name = "MotionTracker"


func _physics_process(delta: float) -> void:
	if _entity != null:
		var prev_position = position
		var prev_velocity = velocity

		position = _entity.global_position
		if !_first_frame:
			velocity = (position - prev_position) / delta
		if !_second_frame:
			acceleration = (velocity - prev_velocity) / delta

		if !_first_frame:
			_second_frame = false
		_first_frame = false
