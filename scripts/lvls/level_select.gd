extends Node2D



func _on_lv_1_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/levels/level_1/scene_1.tscn")


func _on_lv_2_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/levels/level_2/scene_1.tscn")


func _on_lv_3_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/levels/level_3/scene_1.tscn")


func _on_lv_4_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/levels/level_4/scene_1.tscn")


func _on_return_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/main_menu.tscn")


func _on_ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			child.play()


func _on_quit_pressed() -> void:
	get_tree().quit()
