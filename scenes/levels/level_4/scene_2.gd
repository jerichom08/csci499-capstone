extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.saved_player_y = body.global_position.y
		SceneTransition.has_saved_player_y = true
		SceneTransition.target_spawn_name = "LoopSpawn"

		get_tree().call_deferred("change_scene_to_file","res://scenes/levels/level_4/scene_1.tscn")


func _ready() -> void:
	if SceneTransition.has_saved_player_y:
		var player = get_tree().get_first_node_in_group("player")
		var spawn = get_node_or_null(SceneTransition.target_spawn_name)

		if player == null:
			return

		if spawn == null:
			return

		player.global_position = Vector2(
			spawn.global_position.x,
			SceneTransition.saved_player_y
		)

		SceneTransition.has_saved_player_y = false
		SceneTransition.target_spawn_name = ""


func _on_s_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.saved_player_y = body.global_position.y
		SceneTransition.has_saved_player_y = true
		SceneTransition.target_spawn_name = "LoopSpawn"

		get_tree().call_deferred("change_scene_to_file","res://scenes/levels/level_4/scene_2.tscn")


func _on_s_1r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.saved_player_y = body.global_position.y
		SceneTransition.has_saved_player_y = true
		SceneTransition.target_spawn_name = "LoopSpawn2"

		get_tree().call_deferred("change_scene_to_file","res://scenes/levels/level_4/scene_1.tscn")


func _on_s_2r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.saved_player_y = body.global_position.y
		SceneTransition.has_saved_player_y = true
		SceneTransition.target_spawn_name = "LoopSpawn2"

		get_tree().call_deferred("change_scene_to_file","res://scenes/levels/level_4/scene_2.tscn")
