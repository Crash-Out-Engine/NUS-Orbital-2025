class_name Loot
extends Area2D

var item: Item


func _ready() -> void:
	rotation = randf_range(0.0, 360.0)


func setup_scrap_loot(value: int) -> void:
	item = Item.ScrapItem.new(value)


func setup_mod_loots(mod: ModBase) -> void:
	item = Item.ModItem.new(mod)


func move(displacement: Vector2) -> void:
	position += displacement
	_sync_position.rpc(position)


func _on_tree_entered() -> void:
	if is_multiplayer_authority():
		assert(item != null, "Loot should be set up before it enters a tree.")

#region Sync

@rpc("any_peer", "call_remote", "unreliable")
func _sync_position(_position: Vector2) -> void:
	position = _position

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
	item = Item.from_saved(dict.item)
	position = dict.position
	rotation = dict.rotation

#endregion
