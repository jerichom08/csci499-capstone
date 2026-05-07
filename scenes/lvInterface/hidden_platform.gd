extends StaticBody2D

@onready var platform_collision: CollisionShape2D = $CollisionShape2D
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sound_player: AudioStreamPlayer2D = $sound_player

var is_running := false
var is_active := false

func _ready() -> void:
	hide_platform()


func hide_platform() -> void:
	modulate.a = 0.0
	platform_collision.set_deferred("disabled", true)
	area_collision.set_deferred("disabled", true)
	is_active = false


func show_platform() -> void:
	if is_active or is_running:
		return
	
	is_active = true
	
	sound_player.play()
	
	platform_collision.set_deferred("disabled", false)
	area_collision.set_deferred("disabled", false)
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)


func disappear() -> void:
	if is_running:
		return
	
	is_running = true
	
	var tween := create_tween()
	
	# Wait after player steps on it
	tween.tween_interval(1.5)
	
	# Play sound again when disappearing
	tween.tween_callback(func():
		sound_player.play()
	)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	# Turn collision off
	tween.tween_callback(func():
		platform_collision.set_deferred("disabled", true)
		area_collision.set_deferred("disabled", true)
		is_active = false
		is_running = false
	)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_active and not is_running:
		disappear()


func _on_button_button_pressed() -> void:
	show_platform()


func _on_button_2_button_pressed() -> void:
	show_platform()
