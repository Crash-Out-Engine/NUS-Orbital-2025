class_name RangedPlayerComp
extends RangedBaseComp


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return

	if !_entity.hand.locked:
		rotation = _entity.hand.rotation
	
	if !active:
		return
		
	activate()
