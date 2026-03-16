extends Node2D

@onready var spawn_point = $SpawnPoint
@onready var goal = $Goal

var puzzle_completed : bool = false

func _ready():
	goal.body_entered.connect(_on_goal_reached)

func _on_goal_reached(body):
	if body.name != "Player":
		return
	
	if puzzle_completed:
		return
	
	puzzle_completed = true
	print("Puzzle 1 Complete")
	
	# Tell PuzzleManager
	PuzzleManager.complete_puzzle(1)
