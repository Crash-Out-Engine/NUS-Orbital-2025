extends Control

@export var player: Player

@onready var tree := $VBoxContainer/Tree as Tree


func _process(_delta: float) -> void:
	tree.fps.set_text(0,
			"FPS: %0.2f / Physics FPS: %0.2f"
			% [1.0 / Performance.get_monitor(Performance.TIME_PROCESS),
					1.0 / Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)])
	tree.entities.set_text(0,
			"Entities: %s / Misc: %s"
			% [get_tree().current_scene.find_child("EntityContainer").get_child_count(),
			get_tree().current_scene.find_child("MiscContainer").get_child_count()])

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
						$/root/Game.power = INF
						$/root/Game/EntityContainer/Player/Properties/HealthProp.value = INF
						$/root/Game/EntityContainer/Player.scrap = INF
					else:
						$/root/Game.power = 100
						$/root/Game/EntityContainer/Player/Properties/HealthProp.value = 50
						$/root/Game/EntityContainer/Player.scrap = 50

		TreeItem.CELL_MODE_RANGE:
			match item.get_parent().get_text(0):
				"Spawn rate (per sec)":
					$/root/Game/EnemySpawner/SpawnTimer.wait_time = 1.0 / item.get_range(0)
					$/root/Game/EnemySpawner/SpawnTimer.start()
				"Set health":
					$/root/Game/EntityContainer/Player/Properties/HealthProp.value = item.get_range(0)
				"Set scraps":
					$/root/Game/EntityContainer/Player.scrap = item.get_range(0)
