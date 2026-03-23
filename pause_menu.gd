extends Control

func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS

func pause():
	get_tree().paused = true
	visible = true
	
	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1, 0.2)

func resume():
	get_tree().paused = false
	visible = false

func _on_resume_button_pressed():
	resume()

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_settings_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
