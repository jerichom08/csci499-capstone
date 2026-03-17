extends Control

func _ready():
    pause_mode = Node.PAUSE_MODE_PROCESS

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
