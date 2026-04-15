extends Node2D

@export var correct_order : Array[String] = ["bread", "tomato", "apple", "potato"]

var player_sequence : Array[String] = []
var puzzle_completed : bool = false

@onready var ingredient_stations = $IngredientStations
@onready var audio_correct = $AudioCorrect
@onready var audio_wrong = $AudioWrong
@onready var audio_complete = $AudioComplete


func _ready() -> void:
	for station in ingredient_stations.get_children():
		if station.has_signal("ingredient_selected"):
			station.ingredient_selected.connect(_on_ingredient_selected)

	print("Puzzle 2 ready.")
	print("Correct order is: ", correct_order)


func _on_ingredient_selected(ingredient_name: String) -> void:
	if puzzle_completed:
		return

	player_sequence.append(ingredient_name)
	print("Player selected: ", ingredient_name)
	print("Current sequence: ", player_sequence)

	_check_sequence()


func _check_sequence() -> void:
	var current_index = player_sequence.size() - 1

	if player_sequence[current_index] != correct_order[current_index]:
		print("Wrong ingredient. Resetting puzzle.")
		_play_wrong_audio()
		_reset_puzzle()
		return

	print("Correct ingredient.")
	_play_correct_audio()

	if player_sequence.size() == correct_order.size():
		_puzzle_completed()


func _reset_puzzle() -> void:
	player_sequence.clear()
	print("Puzzle reset.")


func _puzzle_completed() -> void:
	puzzle_completed = true
	print("Puzzle completed!")
	_play_complete_audio()

	# Put reward / unlock logic here later
	# Example:
	# $ExitDoor.unlock()
	# PuzzleManager.mark_puzzle_complete("puzzle_2")


func _play_correct_audio() -> void:
	if audio_correct and audio_correct.stream:
		audio_correct.stop()
		audio_correct.play()


func _play_wrong_audio() -> void:
	if audio_wrong and audio_wrong.stream:
		audio_wrong.stop()
		audio_wrong.play()


func _play_complete_audio() -> void:
	if audio_complete and audio_complete.stream:
		audio_complete.stop()
		audio_complete.play()
