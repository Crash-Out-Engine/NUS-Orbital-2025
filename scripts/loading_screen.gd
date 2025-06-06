extends CanvasLayer

@export_file("*.tscn") var next_scene_path: String
@export var parameters: Dictionary

@onready var anim_player = $AnimationPlayer as AnimationPlayer

func _ready():
	ResourceLoader.load_threaded_request(next_scene_path)
	anim_player.play("init")
	if "transitioning" in get_tree().current_scene: get_tree().current_scene.transitioning = true

func _process(_delta: float) -> void:
	if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		if anim_player.is_playing():
			await anim_player.animation_finished
		anim_player.play_backwards("init")
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		var new_node = new_scene.instantiate()
		if "parameters" in new_node: new_node.parameters = parameters #TODO: implement parameters in scenes that can be passed by the loading screen
		var current_scene = get_tree().current_scene
		get_tree().get_root().add_child(new_node)
		get_tree().current_scene = new_node
		reparent(get_tree().current_scene)
		current_scene.queue_free()
		await anim_player.animation_finished
		if "transitioning" in new_node: new_node.transitioning = false
		queue_free()
