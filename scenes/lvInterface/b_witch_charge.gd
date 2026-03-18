extends Sprite2D

var current_frame := 0
var frame_count := 4   # change this to however many frames you have
var speed := 0.1       # time between frames
var timer := 0.0

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= speed:
		timer = 0
		current_frame += 1
		
		if current_frame >= frame_count:
			current_frame = 0
			
		frame = current_frame
