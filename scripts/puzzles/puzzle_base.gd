extends Node2D
class_name PuzzleBase

signal puzzle_completed

var is_completed = false

func start_puzzle() -> void:
	print("Puzzle started:", name)

func complete_puzzle() -> void:
	if is_completed:
		return
	is_completed = true
	print("Puzzle completed:", name)
	emit_signal("puzzle_completed")
