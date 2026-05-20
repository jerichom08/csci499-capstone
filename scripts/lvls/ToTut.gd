extends Area2D

@onready var scene_transition: CanvasLayer = $"../SceneTransition"

func _on_body_entered(body):
	if body.is_in_group("player_intro"):
		scene_transition.change_to_next_demo_scene()
