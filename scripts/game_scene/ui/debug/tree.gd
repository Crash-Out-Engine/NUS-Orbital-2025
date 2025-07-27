extends Tree

var game_seed: TreeItem
var fps: TreeItem
var entities: TreeItem
var time: TreeItem
var spawn_statistics: TreeItem


func _ready(): # TODO: Finish setting up Debug options
	var root = create_item()
	if not is_multiplayer_authority():
		root.set_text(0, "Unavailable in multiplayer.")
		return
	hide_root = true

	# === Statistics ===
	var statistics = root.create_child()
	statistics.set_text(0, "Statistics")

	game_seed = statistics.create_child()
	fps = statistics.create_child()
	entities = statistics.create_child()
	time = statistics.create_child()

	# === Game ===
	var game = root.create_child()
	game.set_text(0, "Game")

	var god = game.create_child()
	god.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	god.set_text(0, "God mode")
	god.set_tooltip_text(0, "Infinite power, health, and scraps (host)")
	god.set_editable(0, true)

	spawn_statistics = statistics.create_child()

	var spawn_rate = game.create_child()
	spawn_rate.set_text(0, "Set enemy spawn rate (per sec)")
	var spawn_rate_range = spawn_rate.create_child()
	spawn_rate_range.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	spawn_rate_range.set_range_config(0, 0, 100, 0.1, true)
	spawn_rate_range.set_editable(0, true)

	var power = game.create_child()
	power.set_text(0, "Set power")
	var power_range = power.create_child()
	power_range.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	power_range.set_range_config(0, 0, 10000, 0.1, true)
	power_range.set_editable(0, true)

	# === Player ===
	var player = root.create_child()
	player.set_text(0, "Player")

	var health = player.create_child()
	health.set_text(0, "Set health")
	var health_range = health.create_child()
	health_range.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	health_range.set_range_config(0, -1, 50, 0.1)
	health_range.set_editable(0, true)

	var scraps = player.create_child()
	scraps.set_text(0, "Set scraps")
	var scraps_range = scraps.create_child()
	scraps_range.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	scraps_range.set_range_config(0, -1, 50, 0.1)
	scraps_range.set_editable(0, true)


func _on_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
