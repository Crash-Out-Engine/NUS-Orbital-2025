@tool
class_name Melee extends Node

@export var melee_cooldown: MeleeCooldown
@export var melee_damage: MeleeDamage
@onready var team: String = $"../TargetPriority".team if $"../TargetPriority" != null else ""

func _ready() -> void:
	assert(get_parent() is CharacterBody2D, "Parent should be a CharacterBody2D.")
	
func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is CharacterBody2D:
		return ["Parent should be a CharacterBody2D."]
	return []

func _physics_process(_delta: float) -> void:
	for i in range(get_parent().get_slide_collision_count()):
		var collision = get_parent().get_slide_collision(i)
		var collider = collision.get_collider()
		
		if (collider != null and 
				not collider.is_in_group(team) and 
				collider.get_node_or_null(^"./Hitbox") != null and 
				melee_cooldown.try_melee()):
			collider.get_node_or_null(^"./Hitbox").trigger(melee_damage.get_effect())
