class_name Game
extends Node2D # TODO: Remember to turn on master volume when releasing

signal game_over(message: String) #message contains the cause of the game over

# HACK: power should be a separate system instead of existing within game.gd
var power: float = 100.0
var power_delta: float = 1.0

var game_ongoing: bool

@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider
@onready var player := $EntityContainer/Player as Player
@onready var entity_container := $EntityContainer as Node

func _ready() -> void:
	target_provider.set_entity_container($EntityContainer)
	MotionTracker.attach_to(player) # TODO: move entity container to its own system
	try_connect_ranged(player)
	player.no_lives.connect(func(): end_game("You died"))
	player.turret_spawned.connect(add_entity)
	game_ongoing = true


func _physics_process(delta: float) -> void:
	power -= delta * power_delta
	if power <= 0:
		if game_ongoing:
			end_game("Power has run out")


func try_connect_ranged(entity: Node2D):
	# HACK: Take away reliance on the node being named "Ranged"
	var ranged: RangedBaseComp = entity.get_node_or_null(^"Components/RangedComp")
	if ranged != null:
		ranged.bullet_spawned.connect(add_entity)


func add_entity(entity: Node2D) -> void:
	MotionTracker.attach_to(entity) # TODO: move entity container to its own system
	$EntityContainer.add_child(entity)
	try_connect_ranged(entity)


func add_misc(misc: Node2D) -> void:
	$MiscContainer.add_child(misc)

func end_game(message: String) -> void:
	game_ongoing = false
	game_over.emit(message)
	power_delta = 0.0
	for entity in entity_container.get_children():
		if entity.has_method("deactivate"):
			entity.deactivate()
