extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	SceneTransition.change_scene_to("res://scenes/levels/level_1/scene_1.tscn")
	
	
	
