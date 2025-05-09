extends Node2D


@onready var player := $EntityContainer/Player as Player
@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider

func _ready() -> void:
	target_provider.set_entity_container($EntityContainer)
	try_connect_ranged(player)
	player.turret_spawned.connect(add_entity)

func try_connect_ranged(entity):
	var ranged: RangedBase = entity.get_node_or_null(^"Ranged") # HACK: Take away reliance on the node being named "Ranged"
	if ranged != null:
		ranged.bullet_spawned.connect(add_entity)
			
func add_entity(entity: Node2D) -> void:
	$EntityContainer.add_child(entity)
	try_connect_ranged(entity)
	
func add_misc(misc: Node2D) -> void:
	$MiscContainer.add_child(misc)
