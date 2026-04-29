extends Area2D

const FILE_BEGIN = "res://scenes/levels/level_1/scene_"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var current_scene_file = get_tree().current_scene.scene_file_path
		
		var file_name = current_scene_file.get_file()
		
		var number_str = file_name.replace("scene_", "").replace(".tscn", "")
		
		var next_level_number = int(number_str) + 1

		var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
		
		CoinManager.bank_room_coins()
		
		get_tree().change_scene_to_file(next_level_path)
