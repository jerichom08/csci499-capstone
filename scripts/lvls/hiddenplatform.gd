extends TileMapLayer

func _ready() -> void:
	collision_enabled = false
	modulate.a = 0.0   # start transparent
	visible = true     # must be visible for tween to work

func _on_button_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_interval(0.5)  # wait 1.5 seconds
	collision_enabled = true
	tween.tween_property(self, "modulate:a", 1.0, 0.4)  # fade IN
