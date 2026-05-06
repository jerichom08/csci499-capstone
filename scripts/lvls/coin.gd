extends Area2D

@export var value: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("spin")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		CoinManager.add_room_coin(1)
		
		$AudioStreamPlayer2D.play()
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.visible = false
		
		await $AudioStreamPlayer2D.finished
		queue_free()
