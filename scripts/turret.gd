class_name Turret
extends StaticBody2D

enum State {
	DEFAULT,
	PLACING,
	PLANNED,
	BUILDING,
	OPERATIONAL,
	DESTROYED,
	CANCELLED,
}

const BLEED_TIME = 0.125
const V_MODULATE = 100000000

var state: State:
	set(value):
		var prev_state = state
		state = value
		if prev_state != state:
			handle_state_changed(prev_state, state)
var player: Player

@onready var _team: String = $TargetPriority.team
@onready var body_sprite = $Ranged/GunSprite


func _ready() -> void:
	state = State.PLACING
	$BaseSprite.rotation = randf_range(0.0, 360.0)
	$Health.just_emptied.connect(func(): state = State.DESTROYED)
	$Health.just_reduced.connect(bleed)


func advance_state():
	match state:
		State.PLACING:
			state = State.PLANNED
		State.PLANNED:
			state = State.BUILDING
		State.BUILDING:
			state = State.OPERATIONAL
		State.OPERATIONAL:
			state = State.DESTROYED
		_:
			assert(false, "State should not advance at %s." % State.find_key(state))

	return state


func handle_state_changed(from: State, to: State):
	match [from, to]:
		[_, State.PLACING]:
			set_collidable(false)
			set_visual_modulate(Color(0, 1, 1, 0.5))
			$Ranged.active = false
			$TargetPriority.team = ""

		[_, State.PLANNED]:
			set_collidable(true)
			set_collision_layer_value(1, false)
			set_collision_layer_value(2, true)
			set_collision_mask_value(1, false)
			set_visual_modulate(Color(1, 1, 1, 0.1))

		[_, State.BUILDING]:
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			set_collision_mask_value(1, true)
			set_visual_modulate(Color(1, 1, 1, 0.5))
			$TargetPriority.team = _team

		[_, State.OPERATIONAL]:
			set_visual_modulate(Color(1, 1, 1, 1))
			$Ranged.active = true

		[_, State.DESTROYED]:
			body_sprite.modulate.v = V_MODULATE
			if (player != null): # HACK: turret should not call player code (not that often, at least)
				player.turrets_placed -= 1
				player.turret_cost = (player.turrets_placed + 1) * player.turrets_placed * 5 / 2
				player.scrap_changed.emit()
			queue_free()

		[_, State.CANCELLED]:
			queue_free()

		[_, _]:
			assert(false, "Invalid state change from %s to %s." % [State.find_key(from), State.find_key(to)])


func set_collidable(value: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not value)


func set_visual_modulate(color: Color) -> void:
	$BaseSprite.self_modulate = color
	$Ranged/GunSprite.self_modulate = color


func is_overlapping() -> bool:
	return $PlacementArea.get_overlapping_bodies().any(func(body): return body.get_node_or_null(^"Hitbox") != null)


func _process(delta: float) -> void:
	if (body_sprite.modulate.v > 1.0):
		body_sprite.modulate.v -= V_MODULATE * delta / BLEED_TIME
		if (body_sprite.modulate.v <= 1.0):
			body_sprite.modulate.v = 1.0


func bleed(_amount: float):
	body_sprite.modulate.v = V_MODULATE
