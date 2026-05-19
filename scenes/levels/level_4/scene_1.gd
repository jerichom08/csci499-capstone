extends Node2D


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
