extends GutTest


func test_movement():
	var player := preload("res://scenes/player.tscn").instantiate() as Player
	assert_true(player != null)
	
	add_child_autofree(player)
	
	var curr_position = player.position
	Input.action_press("right")
	await wait_frames(2)
	Input.action_release("right")
	var next_position = player.position
	assert_eq(next_position.y, curr_position.y)
	assert_gt(next_position.x, curr_position.x)
