extends Node2D

# HACK: power should be a separate system instead of existing within game.gd
var power: float = 100.0

@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider
@onready var player := $EntityContainer/Player as Player

func _ready() -> void:
	target_provider.set_entity_container($EntityContainer)
	try_connect_ranged(player)
	player.turret_spawned.connect(add_entity)


func _physics_process(delta: float) -> void:
	power -= delta


func try_connect_ranged(entity: Node2D):
	# HACK: Take away reliance on the node being named "Ranged"
	var ranged: RangedBaseComp = entity.get_node_or_null(^"Components/RangedComp")
	if ranged != null:
		ranged.bullet_spawned.connect(add_entity)


func add_entity(entity: Node2D) -> void:
	$EntityContainer.add_child(entity)
	try_connect_ranged(entity)


func add_misc(misc: Node2D) -> void:
	$MiscContainer.add_child(misc)
