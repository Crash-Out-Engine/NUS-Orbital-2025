class_name Attack
## The attack received by the entity.

var effects: Array[Effect]:
  set(value):
    if effects == Array():
      effects = value
      effects.make_read_only()
var target_filter: TargetFilter:
  set(value):
    if target_filter == null:
      target_filter = value
var origin_type: String:
  set(value):
    if origin_type == String():
      origin_type = value
var origin_id: int:
  set(value):
    if origin_id == int():
      origin_id = value
var origin_path: NodePath:
  set(value):
    if origin_path == NodePath():
      origin_path = value


static func from(entity: Node2D, _effects: Array[Effect], _target_filter: TargetFilter) -> Attack:
  assert(entity.get_script() != null, "Not an entity.")
  var attack = new()
  attack.origin_type = entity.get_script().get_global_name()
  attack.origin_id = entity.get_instance_id()
  attack.origin_path = entity.get_path()
  attack.effects = _effects
  attack.target_filter = _target_filter
  return attack


#region Save/load

func save() -> PackedByteArray:
  var dict := {}
  dict["origin_type"] = origin_type
  dict["origin_id"] = origin_id
  dict["origin_path"] = origin_path
  dict["effects"] = Effect.save_array(effects)
  dict["target_filter"] = target_filter.save()
  return var_to_bytes(dict)


static func from_saved(data: PackedByteArray) -> Attack:
  var dict := bytes_to_var(data) as Dictionary
  var attack = new()
  attack.origin_type = dict["origin_type"]
  attack.origin_id = dict["origin_id"]
  attack.origin_path = dict["origin_path"]
  attack.effects = Effect.from_saved_array(dict["effects"])
  attack.target_filter = TargetFilter.from_saved(dict["target_filter"])
  return attack

#endregion
