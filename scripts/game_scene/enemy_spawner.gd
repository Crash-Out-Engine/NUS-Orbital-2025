extends Node2D

const _ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var active := true
@export var mods : Array[ModBase]

var _player: Player
var _entity_manager: EntityManager
var count: float = 0.0
var rng = RandomNumberGenerator.new()

func setup(player: Player, entity_manager: EntityManager) -> void:
	_player = player
	_entity_manager = entity_manager


func _on_spawn_timer_timeout() -> void: # TODO(multiplayer): Have more elaborate spawning mechanisms
	if active:
		var enemy = _ENEMY_SCENE.instantiate()

		var center = _player.global_position
		var radius = get_viewport_rect().size.length() * 0.6
		var angle_vector = Vector2.from_angle(randf_range(0, 2 * PI))
		enemy.global_position = center + radius * angle_vector
		enemy.type = Enemy.Type.RANGED if rng.randf() < count/800 else Enemy.Type.MELEE
		var limit = floor(count/30) + 1
		var total_mods = 0
		for mod in mods:
			for i in floor(rng.randf_range(0.0, count/50)):
				total_mods += 1
				if total_mods > limit:
					break
				enemy.add_mod(mod)
			if total_mods > limit:
				break
		_entity_manager.add_entity(enemy, self)
		count += 1
