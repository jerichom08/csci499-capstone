extends Node2D
signal puzzle_completed_signal

@export var correct_order: Array[String] = [
	"TestItem",
	"TestItem2",
	"TestItem3",
	"TestItem4"
]
var picked_up_order: Array[String] = []
var puzzle_completed: bool = false

@onready var audio_correct = $AudioCorrect
@onready var audio_complete = $AudioComplete
@onready var gate = $Gate
@onready var items = $Items
@onready var turnip_npc = $TurnipNpc

func _ready() -> void:
	PuzzleManager.register_puzzle(self)

	for item in items.get_children():
		if item.has_signal("item_picked_up"):
			item.item_picked_up.connect(_on_item_picked_up)

	print("Puzzle 2 ready.")
	print("Correct order is:", correct_order)


func _on_item_picked_up(item_name: String) -> void:
	if puzzle_completed:
		return

	picked_up_order.append(item_name)

	print("Picked up item:", item_name)
	print("Current order:", picked_up_order)

	_play_correct_audio()

	if picked_up_order.size() >= correct_order.size():
		_check_sequence()

func _check_sequence() -> void:
	if picked_up_order == correct_order:
		_puzzle_completed()
	else:
		print("Wrong full sequence. Press reset button to try again.")

		if turnip_npc:
			turnip_npc.set_npc_text(
				"That was the wrong order! Press the reset button to try again.",
				true
			)
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
			
			
func _reset_puzzle() -> void:
	get_tree().reload_current_scene()


func _play_correct_audio() -> void:
	if audio_correct and audio_correct.stream:
		audio_correct.stop()
		audio_correct.play()


func _play_complete_audio() -> void:
	if audio_complete and audio_complete.stream:
		audio_complete.stop()
		audio_complete.play()
		
	
