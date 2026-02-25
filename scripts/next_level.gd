extends Area2D

const FILE_BEGIN = "res://scenes/levels/scene_"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
		get_tree().call_deferred("change_scene_to_file", next_level_path)
