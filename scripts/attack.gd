class_name Attack
## The attack received by the entity.

var effects: Array[Effect]
var origin_type: String
var origin_id: int
var origin_path: NodePath


static func from(entity: Node2D, _effects: Array[Effect]) -> Attack:
  assert(entity.get_script() != null, "Not an entity.")
  var attack = new()
  attack.origin_type = entity.get_script().get_global_name()
  attack.origin_id = entity.get_instance_id()
  attack.origin_path = entity.get_path()
  attack.effects = _effects
  return attack


#region Save/load

func save() -> PackedByteArray:
  var dict := {}
  dict["origin_type"] = origin_type
  dict["origin_id"] = origin_id
  dict["origin_path"] = origin_path
  dict["effects"] = Effect.save_array(effects)
  return var_to_bytes(dict)


static func from_saved(data: PackedByteArray) -> Attack:
  var dict := bytes_to_var(data) as Dictionary
  var attack = new()
  attack.origin_type = dict["origin_type"]
  attack.origin_id = dict["origin_id"]
  attack.origin_path = dict["origin_path"]
  attack.effects = Effect.from_saved_array(dict["effects"])
  return attack

#endregion
