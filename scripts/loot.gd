class_name Loot
extends Area2D

var item: Item:
	set(value):
		item = value
		_handle_set_item()

@onready var base_sprite := $BaseSprite as Sprite2D
@onready var overlay_sprite := $OverlaySprite as Sprite2D


func _ready() -> void:
	rotation = randf_range(0.0, 360.0)


func setup_scrap_loot(value: int) -> void:
	item = Item.ScrapItem.new(value)


func setup_mod_loot(mod: Mod) -> void:
	item = Item.ModItem.new(mod)


func move(displacement: Vector2) -> void:
	_synced_move.rpc(displacement)


func _handle_set_item() -> void:
	if not is_node_ready():
		await ready
	match item.type:
		Item.Type.SCRAP:
			base_sprite.frame = 0
			overlay_sprite.visible = false
			scale = Vector2(1.0, 1.0)
		Item.Type.MOD:
			base_sprite.frame = 1
			overlay_sprite.visible = true
			overlay_sprite.texture = item.mod.icon
			scale = Vector2(1.25, 1.25)


func _on_tree_entered() -> void:
	if not is_multiplayer_authority():
		return

	assert(item != null, "Loot should be set up before it enters a tree.")

#region Sync

@rpc("any_peer", "call_local", "reliable")
func _synced_move(displacement: Vector2) -> void:
	position += displacement

#endregion


#region Save/load

func save_scene() -> PackedByteArray:
	var dict = {}
	dict["position"] = position
	dict["rotation"] = rotation
	dict["item"] = item.save()
	return var_to_bytes(dict)

func load_saved_scene(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	position = dict.position
	rotation = dict.rotation
	item = Item.from_saved(dict.item)

#endregion
