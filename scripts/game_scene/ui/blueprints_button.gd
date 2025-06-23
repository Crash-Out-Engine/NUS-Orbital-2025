extends TextureButton

@onready var description_panel = $Description/BlueprintDescriptionPanel

func _ready() -> void:
	$Description.visible = false

func _process(_delta: float) -> void:
	description_panel.global_position = get_global_mouse_position() - Vector2(40, 0)
	if description_panel.global_position.x + description_panel.size.x > get_viewport().size.x:
		description_panel.global_position.x += 80 - description_panel.size.x

func _on_mouse_entered() -> void:
	$Description.visible = true

func _on_mouse_exited() -> void:
	$Description.visible = false
