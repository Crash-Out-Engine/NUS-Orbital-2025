class_name PropertyPoint
extends Resource

@export var icon: AtlasTexture

func get_icon(size: int = 24) ->  String:
	return ("[img={%d}]" % size) + icon.resource_path + "[/img]"
