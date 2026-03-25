extends Area2D

var player_in_range : bool = false

@onready var interaction_label = $InteractionLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_label:
		interaction_label.visible = false


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		# Show the text when player is near
		if interaction_label:
			interaction_label.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		# Hide the text when player leaves
		if interaction_label:
			interaction_label.visible = false
