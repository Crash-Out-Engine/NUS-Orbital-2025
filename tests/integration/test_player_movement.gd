extends GutTest

func test_move_forward():
	var player := preload("res://scenes/player.tscn").instantiate() as Player
	assert_true(player != null)
	
	var curr_position = player.position
	await wait_frames(2)
	var new_position = player.position
	assert_eq(curr_position.x, new_position.x)
	assert_gt(curr_position.y, new_position.y)
