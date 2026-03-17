extends Node

func register_puzzle(puzzle: PuzzleBase) -> void:
	if puzzle == null:
		return
	#fail case
	if not puzzle.puzzle_completed.is_connected(_on_puzzle_completed):
		puzzle.puzzle_completed.connect(_on_puzzle_completed)
		
	print("Manager registered puzzle:", puzzle.name)
	

func _on_puzzle_completed() -> void:
	print("Manager detected puzzle completion")
