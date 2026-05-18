extends Node2D


# Called when the node enters the scene tree for the first time.
func _on_area_2d_body_entered(body: Node2D) -> void:
	SceneTransition.change_scene_to("res://scenes/levels/level_4/scene_6.tscn")
