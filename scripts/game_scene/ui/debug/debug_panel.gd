class_name DebugPanel
extends Control

var player: Player
var _game: Game

@onready var tree := $VBoxContainer/Tree as Tree


func _process(_delta: float) -> void:
	try_debug()
	if visible:
		tree.fps.set_text(0,
				"FPS: %0.2f / Physics FPS: %0.2f"
				% [1.0 / Performance.get_monitor(Performance.TIME_PROCESS),
						1.0 / Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)])
		tree.entities.set_text(0,
				"Entities: %s" % [_game.get_node(^"EntityManager").get_child_count()])


func setup(game: Game) -> void:
	_game = game
	player = _game.get_local_player()


func try_debug():
	if Input.is_action_just_pressed("debug"):
		visible = !visible


func _on_tree_item_edited() -> void: # HACK: Greatly relies on the node paths being correct.
	var item = tree.get_edited()
	match item.get_cell_mode(0):
		TreeItem.CELL_MODE_CHECK:
			match item.get_text(0):
				"God mode":
					if item.is_checked(0):
						_game.get_node(^"PowerManager")._power = abs(INF / 2)
						player.get_node(^"Properties/HealthCapacityProp").value = abs(INF / 2)
						player.get_node(^"Properties/HealthProp").value = abs(INF / 2)
						player.get_node(^"Components/InventoryComp")._scraps = absi(int(INF)) / 2
					else:
						_game.get_node(^"PowerManager")._power = 100
						player.get_node(^"Properties/HealthCapacityProp").value = 50
						player.get_node(^"Properties/HealthProp").value = 50
						player.get_node(^"Components/InventoryComp")._scraps = 50

		TreeItem.CELL_MODE_RANGE:
			match item.get_parent().get_text(0):
				"Spawn rate (per sec)":
					_game.get_node(^"EnemySpawner/SpawnTimer").wait_time = 1.0 / item.get_range(0)
					_game.get_node(^"EnemySpawner/SpawnTimer").start()
				"Set health":
					player.get_node(^"Properties/HealthProp").value = item.get_range(0)
				"Set scraps":
					player.get_node(^"Components/InventoryComp")._scraps = item.get_range(0)
