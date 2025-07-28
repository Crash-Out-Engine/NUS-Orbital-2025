class_name EnemyWave
extends Resource

@export_group("Description")
@export var name: String
@export var description: String

@export_group("Difficulty settings")
@export var difficulty_rating: int
@export var length: float
@export var spawn_time: float
@export var spawn_chances: Array[float] = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

func get_enemy_type(randf: float) -> Enemy.Type:
	var i = 0
	while (randf < spawn_chances[i]):
		i += 1
	return i-1 as Enemy.Type
