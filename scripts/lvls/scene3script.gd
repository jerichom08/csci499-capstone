extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.0   # start transparent
	visible = true     # must be visible for tween to work


func _on_button_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_interval(0.5)  # wait 1.5 seconds
	tween.tween_property(self, "modulate:a", 1.0, 0.4)  # fade IN
