extends Node

var current_puzzle: PuzzleBase

func register_puzzle(puzzle: PuzzleBase):
	current_puzzle = puzzle
	puzzle.connect("puzzle_completed", Callable(self, "_on_puzzle_completed"))
	
func _on_puzzle_completed():
	print("Manager detected puzzle completion")
