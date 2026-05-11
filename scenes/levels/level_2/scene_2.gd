extends Node2D
signal puzzle_completed_signal

@export var required_items: int = 4

var picked_up_items: int = 0
var puzzle_completed: bool = false

@onready var audio_correct = $AudioCorrect
@onready var audio_complete = $AudioComplete
@onready var gate = $Gate
@onready var items = $Items

func _ready() -> void:
	PuzzleManager.register_puzzle(self)

	for item in items.get_children():
		if item.has_signal("item_picked_up"):
			item.item_picked_up.connect(_on_item_picked_up)

	print("Puzzle 2 ready.")
	print("Need to pick up ", required_items, " items.")


func _on_item_picked_up(item_name: String) -> void:
	if puzzle_completed:
		return

	picked_up_items += 1

	print("Picked up item:", item_name)
	print("Items collected:", picked_up_items, "/", required_items)

	_play_correct_audio()

	if picked_up_items >= required_items:
		_puzzle_completed()


func _puzzle_completed() -> void:
	if puzzle_completed:
		return

	puzzle_completed = true
	puzzle_completed_signal.emit()

	print("Puzzle completed!")
	_play_complete_audio()

	if gate:
		gate.visible = false
		gate.collision_layer = 0
		gate.collision_mask = 0

		if gate.has_node("CollisionShape2D"):
			gate.get_node("CollisionShape2D").disabled = true


func _play_correct_audio() -> void:
	if audio_correct and audio_correct.stream:
		audio_correct.stop()
		audio_correct.play()


func _play_complete_audio() -> void:
	if audio_complete and audio_complete.stream:
		audio_complete.stop()
		audio_complete.play()
