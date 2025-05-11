extends Label

var time = 0

func _ready() -> void:
	position = Vector2(get_viewport_rect().size.x/2 - size.x/2, size.y/2)
	reset()

func reset() -> void:
	time = 0.0

var minutes
var seconds

func _process(delta: float) -> void:
	if(!get_tree().paused):
		time += delta
		seconds = int(time)
		minutes = seconds/60
		seconds -= minutes*60
		text = str(minutes) + ":" + ("0" if seconds < 10 else "") + str(seconds)
