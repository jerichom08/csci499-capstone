extends Node2D

@export var speed: float = 160.0
var current_speed: float = 0.0
var is_falling: bool = false

func _physics_process(delta: float) -> void:
	if is_falling:
		position.y += current_speed * delta
		
		if $RayCast2D.is_colliding():
			is_falling = false
			
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
		
	body.die()

func _on_player_detect_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player"):
		return
		
		
	$AnimationPlayer.play("Shake")
	get_tree().call_group("warning_label", "show")
	fall()


func fall() -> void:
	if is_falling:
		return
		
	is_falling = true
	current_speed = speed
	
	await get_tree().create_timer(2.5).timeout
	queue_free()
	
