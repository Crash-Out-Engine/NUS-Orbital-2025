extends Node2D

const _ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const DOWNTIME_ENEMY_WAVE = preload("res://resources/enemy_waves/0_downtime.tres")

@export var active := true
@export var mods : Array[Mod]
@export var enemy_wave: EnemyWave
@export var enemy_wave_list: Array[EnemyWave]

var time_elapsed: float = 0.0
var accumulated_difficulty: int = 0
var current_difficulty: int = 1
var count: float = 0.0
var rng = RandomNumberGenerator.new()
var _player: Player
var _entity_manager: EntityManager

@onready var timer := $SpawnTimer as Timer

func setup(player: Player, entity_manager: EntityManager) -> void:
	_player = player
	_entity_manager = entity_manager


func _on_spawn_timer_timeout() -> void: # TODO(multiplayer): Have more elaborate spawning mechanisms
	if active:
		var enemy_count = 1

		var center = _player.global_position
		var radius = get_viewport_rect().size.length() * 0.6
		var angle_vector = Vector2.from_angle(randf_range(0, 2 * PI))
		var enemy_global_position = center + radius * angle_vector
		var type: Enemy.Type
		var type_seed = randf()
		type = enemy_wave.get_enemy_type(type_seed)
		var total_mods = floor(rng.randf_range(0, count/80))
		var mod_comp: Array[Mod]
		for mod in total_mods:
			mod_comp.append(mods[rng.randi_range(0, 9)])
		for i in enemy_count:
			var new_enemy = _ENEMY_SCENE.instantiate()
			new_enemy.global_position = enemy_global_position
			new_enemy.type = type
			new_enemy.global_position += Vector2(randf_range(-16, 16), randf_range(-16, 16))
			_entity_manager.server_add_entity(new_enemy, self)
			await new_enemy.ready
			for mod in mod_comp:
				new_enemy.add_mod(mod)
		count += 1
		time_elapsed += timer.wait_time
		if time_elapsed >= enemy_wave.length:
			accumulated_difficulty += enemy_wave.difficulty_rating
			if accumulated_difficulty > (current_difficulty * 3 - 1):
				current_difficulty += 1
				enemy_wave = DOWNTIME_ENEMY_WAVE
			else:
				enemy_wave = enemy_wave_list.filter(
					func(wave): return wave.difficulty_rating <= current_difficulty).pick_random()
			timer.wait_time = enemy_wave.spawn_time
			time_elapsed = 0
