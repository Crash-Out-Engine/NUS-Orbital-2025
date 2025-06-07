extends Control

@export var inventory_comp : InventoryComp
@export var modslot_comp : ModSlotComp

func _ready() -> void:
	visible = false

func try_open():
	if Input.is_action_just_pressed("inventory"):
		visible = !visible

	if Input.is_action_just_pressed("esc"):
		if visible:
			visible = false

func is_open() -> bool:
	return visible

func opening_setup(inventory_input: InventoryComp, modslot_input: ModSlotComp):
	inventory_comp = inventory_input
	modslot_comp = modslot_input

func close():
	visible = false
