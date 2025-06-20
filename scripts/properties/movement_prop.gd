class_name MovementProp
extends PropertyBase
## The [MovementProp] node is responsible for controlling the movement of its parent.
##
## The parent should extend [CharacterBody2D] to allow movements, and have a
## property [code]direction: (delta: float) -> [Vector2][/code] that specifies
## its ongoing direction.

## The initial speed of the entity.
@export var initial_speed: float = 200.0
@export var is_player: bool = false
# TODO: separate movement into its own component, moving target_filter with it
@export var target_filter: TargetFilter

@export_group("Properties")
@export var target_priority: TargetPriorityProp
@export var knockback_prop: KnockbackProp = null

var active
var direction: Vector2

func _ready() -> void:
	assert($"../../" is RigidBody2D or (is_player and $"../../" is CharacterBody2D),
			"MovementProp's grandparent should be a RigidBody2D or CharacterBody2D.")

	value = initial_speed
	active = true


func _physics_process(delta: float) -> void:
	if !active: return

	var knockback: Vector2 = Vector2(0, 0)
	if knockback_prop != null:
		knockback = knockback_prop.get_knockback()
	if is_player:
		var player := $"../../" as Player
		player.velocity = player.direction.call(delta).normalized() * value + knockback
		player.move_and_collide(player.velocity * delta)

	else:
		var parent := $"../../" as RigidBody2D
		var target_provider := load("res://resources/target_provider.tres")

		if target_priority != null:
			var target = target_provider.get_target(parent.global_position, target_filter)
			if target != null:
				direction = parent.global_position.direction_to(target.global_position).normalized()
				var impulse = (direction * value + knockback) * parent.mass 
				parent.apply_central_impulse(impulse - parent.linear_velocity * parent.mass)
