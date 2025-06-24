class_name InventoryAudio
extends Node

@onready var fail_sound = $FailSound as AudioStreamPlayer
@onready var success_sound = $SuccessSound as AudioStreamPlayer
@onready var place_item_sound = $PlaceItemSound as AudioStreamPlayer

func play_fail() -> void:
	fail_sound.play()

func play_success() -> void:
	success_sound.play()

func play_place_item() -> void:
	place_item_sound.play()
