class_name MapIcon
extends Sprite2D

var input_map := [] as Array
var output_map := [] as Array[int]

func set_map(i : Array, o : Array[int]) -> void:
	input_map = i
	output_map = o

func swap_icon(value) -> void:
	print(value)
	for i in range(1, input_map.size()):
		if input_map[i] == value:
			frame = output_map[i]
			return
	frame = output_map[0]
