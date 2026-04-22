extends Node2D


func _ready() -> void:
	AudioPlayer._play_music_level()
func _on_start_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/levels/tutorial/room.tscn")

func _on_options_pressed() -> void:
	$SceneTransition.change_scene_to("res://scenes/options.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
