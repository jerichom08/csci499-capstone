extends Area2D

signal npc_completed(npc_id)

@export var npc_id : String = "npc_1"
@export var interact_action : String = "interaction" 
@export var npc_text : String = "Hello there."

@export var requires_correct_answer : bool = false
@export var option_1 : String = "Option 1"
@export var option_2 : String = "Option 2"
@export var option_3 : String = "Option 3"
@export var correct_option : int = 1

var player_in_range : bool = false
var has_been_completed : bool = false
var dialogue_open : bool = false
var waiting_for_answer : bool = false

@onready var interaction_label = $InteractionLabel
@onready var dialogue_label = $DialogueLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_label:
		interaction_label.visible = false

	if dialogue_label:
		dialogue_label.visible = false


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed(interact_action):
		_interact_with_npc()

	if waiting_for_answer:
		check_answer_input()


func _interact_with_npc() -> void:
	if has_been_completed:
		dialogue_label.text = "I already spoke with you."
		dialogue_label.visible = true
		return

	dialogue_label.visible = true

	if requires_correct_answer:
		dialogue_label.text = npc_text + "\n1. " + option_1 + "\n2. " + option_2 + "\n3. " + option_3
		waiting_for_answer = true
	else:
		dialogue_label.text = npc_text
		mark_completed()


func check_answer_input() -> void:
	if Input.is_action_just_pressed("ui_1"):
		evaluate_answer(1)
	elif Input.is_action_just_pressed("ui_2"):
		evaluate_answer(2)
	elif Input.is_action_just_pressed("ui_3"):
		evaluate_answer(3)


func evaluate_answer(selected_option: int) -> void:
	waiting_for_answer = false

	if selected_option == correct_option:
		dialogue_label.text = "Correct!"
		mark_completed()
	else:
		dialogue_label.text = "Wrong answer. Try again."


func mark_completed() -> void:
	has_been_completed = true
	emit_signal("npc_completed", npc_id)

	if interaction_label:
		interaction_label.visible = false

	print("NPC completed: ", npc_id)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		if interaction_label and not has_been_completed:
			interaction_label.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		waiting_for_answer = false

		if interaction_label:
			interaction_label.visible = false

		if dialogue_label:
			dialogue_label.visible = false
