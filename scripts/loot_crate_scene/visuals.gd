extends Node2D

@export var health: HealthProp
@onready var build_progress := $HealthBar as TextureProgressBar

func _ready() -> void:
	health.changed.connect(
			func(_from, to):
				if is_multiplayer_authority():
					_update_health_bar(to)
	)

func _update_health_bar(value: float) -> void:
	var v = (value / health._initial_health) * 100
	build_progress.value = v
	build_progress.visible = v < 100
