extends Node2D

signal puzzle_completed_signal

var is_completed: bool = false

@onready var final_door_area: Area2D = $FinalDoorArea


func _ready() -> void:
	PuzzleManager.register_puzzle(self)

	final_door_area.body_entered.connect(_on_final_door_entered)

	print("Puzzle 1 ready.")


func _on_final_door_entered(body: Node2D) -> void:
	if is_completed:
		return

	if body.is_in_group("Player"):
		is_completed = true
		print("Puzzle 1 completed!")

		puzzle_completed_signal.emit()
