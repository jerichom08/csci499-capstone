extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _on_button_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	# Defer disabling collision to avoid "flushing queries" error
	call_deferred("_disable_collision")

func _disable_collision():
	collision_shape.disabled = true

func _on_button_button_released() -> void:
	# Re-enable collision safely
	collision_shape.disabled = false
	
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
