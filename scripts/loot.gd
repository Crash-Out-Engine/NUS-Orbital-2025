class_name Loot
extends Area2D

var item: Item

@onready var base_sprite = $BaseSprite as Sprite2D
@onready var overlay_sprite = $OverlaySprite as Sprite2D


func _ready() -> void:
	rotation = randf_range(0.0, 360.0)
	match(item.type):
		Item.Type.SCRAP:
			base_sprite.frame = 0
			overlay_sprite.visible = false
			scale = Vector2(1, 1)
		Item.Type.MOD:
			base_sprite.frame = 1
			overlay_sprite.visible = true
			overlay_sprite.texture = item.mod.icon
			scale = Vector2(2, 2)


func setup_scrap_loot(value: int) -> void:
	item = Item.ScrapItem.new(value)


func setup_mod_loots(mod: ModBase) -> void:
	item = Item.ModItem.new(mod)


func _on_tree_entered() -> void:
	assert(item != null, "Loot should be set up before it enters a tree.")
