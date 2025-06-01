extends GutTest

const _PLAYER_SCENE = preload("res://scenes/player.tscn")

func test_move_forward():
	var player := _PLAYER_SCENE.instantiate() as Player
	assert_true(player != null)

	add_child_autofree(player)

	var curr_position = player.position
	Input.action_press("up")
	await wait_frames(2)
	Input.action_release("up")
	var new_position = player.position
	assert_eq(curr_position.x, new_position.x)
	assert_gt(curr_position.y, new_position.y)
