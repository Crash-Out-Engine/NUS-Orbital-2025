class_name Loot
extends Area2D

var item: Item


func _ready() -> void:
	rotation = randf_range(0.0, 360.0)


func setup_scrap_loot(value: int) -> void:
	item = Item.ScrapItem.new(value)


func setup_mod_loots(mod: ModBase) -> void:
	item = Item.ModItem.new(mod)


func _on_tree_entered() -> void:
	assert(item != null, "Loot should be set up before it enters a tree.")
