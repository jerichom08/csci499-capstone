extends Camera2D

signal line_drawn
signal circle_drawn
signal triangle_drawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_zoom(Vector2(1.0,1.0))


func _on_canvas_circle_drawn() -> void:
	emit_signal("circle_drawn")


func _on_canvas_line_drawn() -> void:
	emit_signal("line_drawn")


func _on_canvas_triangle_drawn() -> void:
	emit_signal("triangle_drawn")
