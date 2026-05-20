extends Node

var demo_scenes := [
	"res://scenes/levels/tutorial/room.tscn",
	"res://scenes/levels/tutorial/scene_6.tscn",
	"res://scenes/levels/level_1/scene_7.tscn",
	"res://scenes/levels/level_2/scene_3.tscn",
	"res://scenes/levels/level_3/scene_4.tscn",
	"res://scenes/levels/level_4/scene_1.tscn",
	"res://scenes/levels/level_4/scene_6.tscn"
]

var current_index := -1

func next_scene():
	current_index += 1

	if current_index >= demo_scenes.size():
		return

	get_tree().change_scene_to_file(demo_scenes[current_index])
