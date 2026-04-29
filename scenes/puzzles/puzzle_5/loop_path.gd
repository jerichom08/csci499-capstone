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
		print("Interaction pressed on path:", path_name)
		var puzzle = get_parent().get_parent()
		if puzzle and puzzle.has_method("choose_path"):
			print("choose_path found on puzzle")
			puzzle.choose_path(path_name, player_ref)
		else:
			print("Puzzle not found or choose_path missing")

func _on_body_entered(body: Node) -> void:
	print("Something entered:", body.name)
	if body.name == "Player":
		print("Player detected")
		player_in_range = true
		player_ref = body
		if interaction_label:
			interaction_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		print("Player exited")
		player_in_range = false
		player_ref = null
		if interaction_label:
			interaction_label.visible = false
