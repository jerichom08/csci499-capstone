extends Node2D
class_name PuzzleBase

signal puzzle_completed

var is_completed = false

func start_puzzle():
	print("Puzzle started")
	
func complete_puzzle():
	if not is_completed:
		is_completed = true
		emit_signal("puzzle_completed")
		print("Puzzle completed")
