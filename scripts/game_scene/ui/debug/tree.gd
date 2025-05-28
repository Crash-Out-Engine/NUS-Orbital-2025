extends Tree

var fps: TreeItem
var entities: TreeItem


func _ready(): # TODO: Finish setting up Debug options
	var root = create_item()
	hide_root = true
	
	# === Statistics ===
	var statistics = root.create_child()
	statistics.set_text(0, "Statistics")

	fps = statistics.create_child()
	entities = statistics.create_child()

	# === Game ===
	var game = root.create_child()
	game.set_text(0, "Game")

	var power = game.create_child()
	power.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	power.set_text(0, "God mode")
	power.set_tooltip_text(0, "Infinite power, health, and scraps")
	power.set_editable(0, true)

	# === Player ===
	var player = root.create_child()
	player.set_text(0, "Player")
	
	var health = player.create_child()
	health.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	health.set_text(0, "Set health")
	health.set_editable(0, true)
	
	var scraps = player.create_child()
	scraps.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	scraps.set_text(0, "Set scraps")
	scraps.set_editable(0, true)


func _on_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
