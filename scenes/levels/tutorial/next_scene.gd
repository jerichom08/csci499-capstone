extends Area2D


const FILE_BEGIN = "res://scenes/levels/tutorial/scene_"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		CoinManager.bank_room_coins()
		DemoManager.next_scene()
