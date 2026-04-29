extends Node

var completed_puzzles: Dictionary = {}
var puzzle_start_times: Dictionary = {}
var puzzle_completion_times: Dictionary = {}


func register_puzzle(puzzle: Node) -> void:
	if puzzle == null:
		return

	if not puzzle.has_signal("puzzle_completed_signal"):
		print("This puzzle does not have puzzle_completed_signal: ", puzzle.name)
		return

	if not puzzle.puzzle_completed_signal.is_connected(_on_puzzle_completed):
		puzzle.puzzle_completed_signal.connect(_on_puzzle_completed.bind(puzzle))

	puzzle_start_times[puzzle.name] = Time.get_ticks_msec()

	print("Manager registered puzzle: ", puzzle.name)
	print("Timer started for: ", puzzle.name)


func _on_puzzle_completed(puzzle: Node) -> void:
	var puzzle_name = puzzle.name

	if completed_puzzles.has(puzzle_name):
		return

	completed_puzzles[puzzle_name] = true

	var elapsed_seconds := 0.0

	if puzzle_start_times.has(puzzle_name):
		var end_time = Time.get_ticks_msec()
		var start_time = puzzle_start_times[puzzle_name]
		elapsed_seconds = float(end_time - start_time) / 1000.0
		puzzle_completion_times[puzzle_name] = elapsed_seconds

	print("Manager detected puzzle completion: ", puzzle_name)
	print("Time taken: ", elapsed_seconds, " seconds")


func is_completed(puzzle_name: String) -> bool:
	return completed_puzzles.has(puzzle_name)


func get_time(puzzle_name: String) -> float:
	if puzzle_completion_times.has(puzzle_name):
		return puzzle_completion_times[puzzle_name]

	return -1.0
