class_name Loot
extends Area2D

var value = 1 # scrap can have multiple types of values to accomodate for large
							# numbers of scrap rewards without spawning too much of the same
							# scene. The sprite will have to change accordingly.


func _ready() -> void:
	rotation = randf_range(0.0, 360.0)
