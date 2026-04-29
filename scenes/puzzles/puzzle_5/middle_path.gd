extends Area2D

@export var path_name: String = "top"
@export var interact_action: String = "interaction"

var player_in_range: bool = false
var player_ref: Node2D = null

@onready var interaction_label = $InteractionLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_label:
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed(interact_action):
		var puzzle = get_parent().get_parent()
		if puzzle and puzzle.has_method("choose_path"):
			puzzle.choose_path(path_name, player_ref)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		player_ref = body
		if interaction_label:
			interaction_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_ref = null
		if interaction_label:
			interaction_label.visible = false
