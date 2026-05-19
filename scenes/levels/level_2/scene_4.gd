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

	if turnip_npc.has_signal("npc_interacted"):
		turnip_npc.npc_interacted.connect(_check_sequence)

	print("Puzzle 2 ready.")
	print("Correct order is:", correct_order)


func _on_item_picked_up(item_name: String) -> void:
	if puzzle_completed:
		return

	picked_up_order.append(item_name)

	print("Picked up item:", item_name)
	print("Current order:", picked_up_order)

	_play_correct_audio()


func _check_sequence() -> void:
	if puzzle_completed:
		return

	if picked_up_order.size() < correct_order.size():
		if turnip_npc:
			turnip_npc.show_temporary_text("Collect all the cookies first.")
		return

	if picked_up_order == correct_order:
		if turnip_npc:
			turnip_npc.set_npc_text("You're free to go! [ E ]", true)
		_clear_player_last_items() 
		_puzzle_completed()
	else:
		print("Wrong sequence. Try again.")

		if turnip_npc:
			turnip_npc.show_temporary_text("Try again! [ E ]")

		_clear_player_last_items()
		_reset_items()


func _clear_player_last_items() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player and player.has_method("remove_last_items"):
		player.remove_last_items(correct_order.size())


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


func _reset_items() -> void:
	picked_up_order.clear()

	for item in items.get_children():
		if item.has_method("respawn"):
			item.respawn()


func _play_correct_audio() -> void:
	if audio_correct and audio_correct.stream:
		audio_correct.stop()
		audio_correct.play()


func _play_complete_audio() -> void:
	if audio_complete and audio_complete.stream:
		audio_complete.stop()
		audio_complete.play()
