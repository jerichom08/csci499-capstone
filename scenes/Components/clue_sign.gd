extends Area2D

@export var interact_action : String = "interact"

var player_in_range : bool = false
var clue_open : bool = false

@onready var interaction_label = $InteractionLabel
@onready var clue_text = $ClueText

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_label:
		interaction_label.visible = false

	if clue_text:
		clue_text.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed(interact_action):
		_toggle_clue()

func _toggle_clue() -> void:
	clue_open = not clue_open

	if clue_text:
		clue_text.visible = clue_open

	if interaction_label:
		interaction_label.visible = not clue_open and player_in_range

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		if interaction_label and not clue_open:
			interaction_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_label:
			interaction_label.visible = false

		if clue_text:
			clue_text.visible = false

		clue_open = false
