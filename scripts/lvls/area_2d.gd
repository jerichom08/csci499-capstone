extends Area2D

@onready var scene_transition: CanvasLayer = $"../SceneTransition"

func _on_body_entered(body):
	if body.is_in_group("player"):
		scene_transition.change_scene_to("res://scenes/levels/tutorial/scene_1.tscn")
