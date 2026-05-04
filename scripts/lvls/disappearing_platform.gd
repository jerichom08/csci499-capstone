extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sound_player: AudioStreamPlayer2D = $sound_player

var is_running := false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_running:
		disappear()
		

func disappear() -> void:
	is_running = true
	
	var tween = create_tween()
	# wait
	tween.tween_interval(1.5)
	
	tween.tween_callback(func(): sound_player.play())
	
	# Fade out
	
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	tween.tween_callback(func(): collision_shape_2d.disabled = true)
	
	# wait 
	tween.tween_interval(3.0)
	
	# Re-enable collision
	tween.tween_callback(func(): collision_shape_2d.disabled = false)
	
	# Fade back in
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	
	# Reset flag
	tween.tween_callback(func(): is_running = false)
