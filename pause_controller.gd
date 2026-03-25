extends Node

@onready var pause_menu = $PauseMenu

func _input(event):

    if event.is_action_pressed("ui_cancel"):

        if get_tree().current_scene.name == "MainMenu":
            return

        if pause_menu.visible:
            pause_menu.resume()
        else:
            pause_menu.pause()
