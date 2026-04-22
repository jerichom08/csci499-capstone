extends TextureRect

signal line_drawn
signal circle_drawn
signal triangle_drawn

@export var paint_color : Color = Color(0.4, 0.631, 0.675, 1.0)
@export var img_size := Vector2i(128, 128)
@export var brush_size := 2

var img : Image

func _ready() -> void:
	set_process_input(true)
	img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	texture = ImageTexture.create_from_image(img)
	

func _paint_tex(pos) -> void:
	img.fill_rect(Rect2i(pos, Vector2i(1, 1)).grow(brush_size), paint_color)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var pos = get_local_mouse_position()
				_paint_tex(pos)
				texture.update(img)
			else:
				_detect_shape()
				_clear_canvas()
				
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			var pos = get_local_mouse_position()
			
			if event.relative.length_squared() > 0:
				var num := ceili(event.relative.length())
				var target_pos = pos - (event.relative)
				for i in range(num):
					pos = pos.move_toward(target_pos, 1.0)
					_paint_tex(pos)
					
					
			texture.update(img)

func _clear_canvas() -> void:
	img.fill(Color.TRANSPARENT)
	texture.update(img)
	
func _get_drawn_pixels():
	var pixels = []
	
	for x in range(img_size.x):
		for y in range(img_size.y):
			var c = img.get_pixel(x, y)
			if c!= Color.TRANSPARENT:
				pixels.append(Vector2(x, y))
	
	return pixels

func _get_edge_pixels():
	var edges = []
	for x in range(1, img_size.x - 1):
		for y in range(1, img_size.y - 1):
			if img.get_pixel(x, y) != Color.TRANSPARENT:
				if img.get_pixel(x+1,y) == Color.TRANSPARENT \
				or img.get_pixel(x-1,y) == Color.TRANSPARENT \
				or img.get_pixel(x,y+1) == Color.TRANSPARENT \
				or img.get_pixel(x,y-1) == Color.TRANSPARENT:
					edges.append(Vector2(x,y))
	return edges

func _get_bounds(pixels):
	var min_x = pixels[0].x
	var max_x = pixels[0].x
	var min_y = pixels[0].y
	var max_y = pixels[0].y
	
	for p in pixels:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
		
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func _is_circle(points):
	var center = Vector2.ZERO
	for p in points:
		center += p
	center /= points.size()
	
	var distances = []
	var avg = 0.0
	for p in points:
		var d = p.distance_to(center)
		distances.append(d)
		avg += d
	avg /= distances.size()
	
	var variance = 0.0
	for d in distances:
		variance += pow(d - avg, 2)
	variance /= distances.size()
	
	var stddev = sqrt(variance)
	print(stddev)
	return stddev < 6.5

func _is_line(points):
	var bounds = _get_bounds(points)
	var w = bounds.size.x
	var h = bounds.size.y
	
	if h == 0 or w == 0:
		return false
		
	var ratio = max(w, h) / min(w, h)
	return ratio > 4.0

func _detect_shape() -> void:
	var points = _get_edge_pixels()
	
	if points.size() < 30:
		return
		
	if _is_line(points):
		print("Line")
		emit_signal("line_drawn")
		return
		
	if _is_circle(points):
		print("Circle")
		emit_signal("circle_drawn")
		return
	
	print("Triangle")
	emit_signal("triangle_drawn")
	
