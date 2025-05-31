extends GutTest

var _sender = InputSender.new(Input)


func after_each():
	_sender.release_all()
	_sender.clear()


func test_movement():
	var player := preload("res://scenes/player.tscn").instantiate() as Player
	assert_true(player != null)
	
	add_child_autofree(player)
	
	var curr_position = player.position
	_sender.action_down("right").wait_frames(1)
	await _sender.idle
	
	await wait_frames(2)
	_sender.action_up("right")
	var next_position = player.position
	assert_eq(next_position.y, curr_position.y)
	assert_gt(next_position.x, curr_position.x)
