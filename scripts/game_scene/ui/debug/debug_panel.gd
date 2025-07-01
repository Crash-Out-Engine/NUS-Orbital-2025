extends Control

var active: bool = false
var _player: Player
var _entity_manager: EntityManager
var _power_manager: PowerManager
var _enemy_spawner: Node

@onready var tree := $VBoxContainer/Tree as Tree


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if not active:
		return

	tree.fps.set_text(0,
			"FPS: %0.2f / Physics FPS: %0.2f"
			% [1.0 / Performance.get_monitor(Performance.TIME_PROCESS),
					1.0 / Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)])
	tree.entities.set_text(0,
			"Entities: %s"
			% _entity_manager.get_child_count())


func setup(
		player: Player,
		entity_manager: EntityManager,
		power_manager: PowerManager,
		enemy_spawner: Node) -> void:
	_player = player
	_entity_manager = entity_manager
	_power_manager = power_manager
	_enemy_spawner = enemy_spawner

	active = true


func toggle_debug():
	visible = !visible


func _on_tree_item_edited() -> void:
	if not is_multiplayer_authority():
		return

	var item = tree.get_edited()
	match item.get_cell_mode(0):
		TreeItem.CELL_MODE_CHECK:
			match item.get_text(0):
				"God mode":
					if item.is_checked(0):
						_power_manager._power = abs(INF / 2)
						_player.get_node(^"Properties/HealthCapacityProp").value = absi(int(INF) / 2)
						_player.get_node(^"Properties/HealthProp").value = absi(int(INF) / 2)
						_player.get_node(^"Components/InventoryComp")._scraps = absi(int(INF) / 2)
					else:
						_power_manager._power = _power_manager._initial_power
						var health_capacity_prop := (
								_player.get_node(^"Properties/HealthCapacityProp") as HealthCapacityProp)
						health_capacity_prop.value = health_capacity_prop._initial_health_capacity
						var health_prop := _player.get_node(^"Properties/HealthProp") as HealthProp
						health_prop.value = health_prop._initial_health
						var inventory_comp := _player.get_node(^"Components/InventoryComp") as InventoryComp
						inventory_comp._scraps = inventory_comp.initial_scraps

		TreeItem.CELL_MODE_RANGE:
			match item.get_parent().get_text(0):
				"Set enemy spawn rate (per sec)":
					_enemy_spawner.wait_time = 1.0 / item.get_range(0)
					_enemy_spawner.get_node(^"SpawnTimer").start()
				"Set power":
					_power_manager._power = item.get_range(0)
				"Set health":
					_player.get_node(^"Properties/HealthProp").value = item.get_range(0)
				"Set scraps":
					_player.get_node(^"Components/InventoryComp")._scraps = item.get_range(0)
