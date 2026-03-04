extends Node2D

@export var speed: float = 160.0
var current_speed: float = 0.0
var is_falling: bool = false

func _physics_process(delta: float) -> void:
	if is_falling:
		position.y += current_speed * delta


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name != "Player":
		return
		
	get_tree().call_deferred("reload_current_scene")

func _on_player_detect_area_entered(area: Area2D) -> void:
	print("PlayerDetect triggered")
	if area.name != "Player":
		return
		
	$AnimationPlayer.play("Shake")
	fall()

func fall() -> void:
	if is_falling:
		return
		
	is_falling = true
	current_speed = speed
	
	await get_tree().create_timer(5.0).timeout
	queue_free()
