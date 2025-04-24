@tool
class_name Melee extends Node

@export var melee_cooldown: MeleeCooldown
@export var melee_damage: MeleeDamage
@onready var team: String = $"../TargetPriority".team if $"../TargetPriority" != null else ""

func _ready() -> void:
	assert(get_parent() is RigidBody2D, "Parent should be a RigidBody2D.")
	
func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is RigidBody2D:
		return ["Parent should be a RigidBody2D."]
	return []

func _physics_process(_delta: float) -> void:
	for collider in get_parent().get_colliding_bodies():
		
		if (collider != null and 
				#not collider.is_in_group(team) and  # TODO: Don't rely on godot groups
				collider.get_node_or_null(^"./Hitbox") != null and 
				melee_cooldown.try_melee()):
			collider.get_node_or_null(^"./Hitbox").trigger(melee_damage.get_effect())
