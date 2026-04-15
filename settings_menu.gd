extends Control

@onready var volume_slider = $VBoxContainer/VolumeSlider
@onready var back_button = $VBoxContainer/BackButton

func _ready():
    # Set default volume (optional)
    volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

    # Make sure UI works while paused
    pause_mode = Node.PAUSE_MODE_PROCESS

# 🎧 Volume control
func _on_volume_slider_value_changed(value):
    AudioServer.set_bus_volume_db(0, linear_to_db(value))

# 🔙 Back button
func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
