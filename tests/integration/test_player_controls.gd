extends GutTest

const _PLAYER_SCENE = preload("res://scenes/player.tscn")

func test_move_forward():
	var player = add_child_autofree(_PLAYER_SCENE.instantiate())
	assert_true(player != null)
	
	var sender := GutInputSender.new(player)
	sender.add_receiver(Input)

	var curr_position = player.position
	sender.key_down(KEY_D).action_down("right").hold_for(1).wait("10f")
	await sender.idle
	var new_position = player.position
	assert_lt(curr_position.x, new_position.x)
	assert_eq(curr_position.y, new_position.y)
