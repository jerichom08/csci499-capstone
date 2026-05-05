extends Area2D

@export var path_name: String = "top"

var player_inside: bool = false
var puzzle_ref: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

		if puzzle_ref == null:
			puzzle_ref = get_parent()

		if puzzle_ref and puzzle_ref.has_method("choose_path"):
			puzzle_ref.choose_path(path_name)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
