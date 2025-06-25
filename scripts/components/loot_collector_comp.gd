class_name LootCollectorComp
extends Area2D

const LOOT_SPEED: float = 250
const CONSUME_RADIUS: float = 3

@export_group("Components")
@export var inventory: InventoryComp

var _loots: Array[Loot] = []


func _ready() -> void:
	area_entered.connect(_handle_area_entered)


func _physics_process(delta: float) -> void:
	_loots = _loots.filter(func(loot): return loot != null)
	for loot in _loots:
		if loot == null:
			continue

		var displacement = (global_position - loot.global_position)

		if displacement.length() < CONSUME_RADIUS:
			inventory.register_item(loot.item)
			loot.queue_free()
			continue

		var direction = displacement.normalized()
		loot.move(direction * LOOT_SPEED * delta)


func _handle_area_entered(area: Area2D) -> void:
	if area is not Loot:
		return

	_loots.append(area)
