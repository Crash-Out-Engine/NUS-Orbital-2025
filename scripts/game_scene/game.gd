class_name Game
extends Node2D # TODO: Remember to turn on master volume when releasing

signal game_over(message: String) #message contains the cause of the game over

var transitioning: bool
var game_seed: int

@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider
@onready var player := $EntityContainer/Player as Player
@onready var entity_container := $EntityContainer as Node
@onready var power_manager := $PowerManager as PowerManager

func _ready() -> void:
	transitioning = true
	target_provider.set_entity_container($EntityContainer)
	MotionTracker.attach_to(player) # TODO: move entity container to its own system
	try_connect_ranged(player)
	player.lives_depleted.connect(func(): end_game("You died"))
	player.entity_spawned.connect(add_entity)
	power_manager.power_depleted.connect(func():
		end_game("Power has run out")
	)
	$WorldGenSystem.setup(self)


func get_power() -> float:
	return power_manager.get_power()


func try_connect_ranged(entity: Node2D):
	var components_node = entity.get_node_or_null(^"Components")
	if components_node != null:
		var ranged_comps := (components_node
				.get_children()
				.filter(func(node): return node is RangedBaseComp))
		for ranged_comp: RangedBaseComp in ranged_comps:
			ranged_comp.bullet_spawned.connect(add_entity)


func add_entity(entity: Node2D) -> void:
	MotionTracker.attach_to(entity) # TODO: move entity container to its own system
	$EntityContainer.add_child(entity)
	if entity is Fault:
		power_manager.register_fault(entity)
	try_connect_ranged(entity)


func end_game(message: String) -> void:
	game_over.emit(message)
	power_manager.active = false
	for entity in entity_container.get_children():
		if entity.has_method("deactivate"):
			entity.deactivate()


func get_local_player() -> Player:
	return player # TODO(multiplayer): implement local player


func get_seed() -> int:
	if game_seed == 0: # TODO(multiplayer): implement seed synchronization
		game_seed = randi()
	return game_seed
