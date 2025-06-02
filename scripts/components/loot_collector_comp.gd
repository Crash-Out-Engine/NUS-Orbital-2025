class_name LootCollectorComp
extends Area2D

const LOOT_SPEED: float = 250
const CONSUME_RADIUS: float = 3

@export var player: Player

var _loots: Array[Loot] = []


func _ready() -> void:
	area_entered.connect(_handle_area_entered)


func _physics_process(delta: float) -> void:
	for loot in _loots:
		var displacement = (global_position - loot.global_position)

		if displacement.length() < CONSUME_RADIUS:
			player.gain_scrap(loot.value)
			loot.queue_free()
			_loots.erase(loot)
			continue

		var direction = displacement.normalized()
		loot.global_position += direction * LOOT_SPEED * delta


func _handle_area_entered(area: Area2D) -> void:
	if area is not Loot:
		return

	_loots.append(area)
