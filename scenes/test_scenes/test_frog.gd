extends Node2D

func _ready() -> void:
	var frog = get_node("frog")
	frog.play_heal_sequence()
