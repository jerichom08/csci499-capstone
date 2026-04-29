extends Camera2D

var locked_y := 360.0

func _ready():
	global_position.y = locked_y

func _process(_delta):
	position.y = 0
	global_position.y = locked_y
