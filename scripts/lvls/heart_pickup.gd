extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("spin")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.heal(2)
		
		$AudioStreamPlayer2D.play()
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.visible = false
		
		await $AudioStreamPlayer2D.finished
		
		queue_free()
