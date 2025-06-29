extends Node2D

const _ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var active := true
@export var mods : Array[ModBase]

var count: float = 0.0
var rng = RandomNumberGenerator.new()
var _player: Player
var _entity_manager: EntityManager

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
		var total_mods = floor(rng.randf_range(0, count/80))
		_entity_manager.add_entity(enemy, self)
		await enemy.ready
		for i in total_mods:
			var temp = rng.randf_range(0, 9)
			enemy.add_mod(mods[temp])
		count += 1
