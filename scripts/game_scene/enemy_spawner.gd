extends Node2D

const _ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var active := true
@export var mods : Array[Mod]
@export var curve: Curve

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
		var enemy_count = 1

		var center = _player.global_position
		var radius = get_viewport_rect().size.length() * 0.6
		var angle_vector = Vector2.from_angle(randf_range(0, 2 * PI))
		enemy.global_position = center + radius * angle_vector
		enemy.type = randi_range(0, 4)
		var type = randf()
		match true:
			_ when type < 0.7:
				enemy.type = 0
			_ when type >= 0.7 && type < 0.9:
				enemy.type = 1
			_ when type >= 0.9 && type < 0.95:
				enemy.type = 2
				enemy_count = randi_range(6, 10)
			_ when type >= 0.95 && type < 0.975:
				enemy.type = 3
			_ when type >= 0.975:
				enemy.type = 4
		var total_mods = floor(rng.randf_range(0, count/80))
		var mod_comp: Array[Mod]
		for mod in total_mods:
			mod_comp.append(mods[rng.randi_range(0, 9)])
		for i in enemy_count:
			var new_enemy = enemy.duplicate()
			new_enemy.type = enemy.type
			new_enemy.global_position += Vector2(randf_range(-16, 16), randf_range(-16, 16))
			_entity_manager.server_add_entity(new_enemy, self)
			await new_enemy.ready
			for mod in mod_comp:
				new_enemy.add_mod(mod)
		count += 1
