extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

@onready var player: Player = $Entities/Player as Player
@onready var target_provider = TargetProvider.new(func (): return $Entities)

func _ready() -> void:
	try_connect_ranged(player)
	player.turret_spawned.connect(add_entity)


func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	enemy.global_position = player.global_position
	enemy.global_position += get_viewport_rect().size.length() * 0.6 * Vector2.from_angle(randf_range(0, 2 * PI))
	
	enemy.look_at(player.global_position)
	add_entity(enemy)
	enemy.vfx_emitted.connect(add_misc)

func try_connect_ranged(entity):
	var ranged: Ranged = entity.get_node_or_null(^"Ranged")
	if ranged != null:
		entity.target_provider = target_provider
		ranged.bullet_spawned.connect(add_entity)
			
func add_entity(entity: Node2D) -> void:
	$Entities.add_child(entity)
	try_connect_ranged(entity)
	
func add_misc(misc: Node2D) -> void:
	$Misc.add_child(misc)


func _on_entities_child_entered_tree(node: Node) -> void:
	if target_provider != null:
		target_provider.refresh()


func _on_entities_child_exiting_tree(node: Node) -> void:
	if target_provider != null:
		target_provider.refresh()
