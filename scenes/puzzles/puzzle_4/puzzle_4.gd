extends Node2D
signal puzzle_completed_signal

@onready var npc_1 = $NPC_1
@onready var npc_2 = $NPC_2
@onready var npc_3 = $NPC_3
@onready var npc_4 = $NPC_4
@onready var puzzle_status_label = $PuzzleStatusLabel
@onready var reset_button = $Button

var completed_npcs : Dictionary = {
	"npc_1": false,
	"npc_2": false,
	"npc_3": false,
	"npc_4": false
}

var puzzle_completed : bool = false


func _ready() -> void:
	PuzzleManager.register_puzzle(self)
	connect_npc(npc_1, "NPC_1")
	connect_npc(npc_2, "NPC_2")
	connect_npc(npc_3, "NPC_3")
	connect_npc(npc_4, "NPC_4")
	if reset_button:
		reset_button.button_pressed.connect(_on_reset_button_pressed)

	update_status_label()


func connect_npc(npc_node: Node, name: String) -> void:
	if npc_node == null:
		print("Missing node:", name)
		return

	if npc_node.has_signal("npc_completed"):
		npc_node.npc_completed.connect(_on_npc_completed)
	else:
		print(name, "does not have npc_completed signal")


func _on_npc_completed(npc_id: String) -> void:
	if completed_npcs.has(npc_id):
		completed_npcs[npc_id] = true

	update_status_label()
	check_puzzle_complete()


func check_puzzle_complete() -> void:
	for npc_id in completed_npcs.keys():
		if not completed_npcs[npc_id]:
			return

	puzzle_completed = true

	if puzzle_status_label:
		puzzle_status_label.text = "Puzzle Complete!"

	print("Puzzle 4 completed!")
	puzzle_completed_signal.emit()


func update_status_label() -> void:
	var total_done := 0

	for npc_id in completed_npcs.keys():
		if completed_npcs[npc_id]:
			total_done += 1

	if puzzle_status_label and not puzzle_completed:
		puzzle_status_label.text = "Talked to %d / 4 NPCs" % total_done

func _on_reset_button_pressed() -> void:
	reset_puzzle()


func reset_puzzle() -> void:
	completed_npcs["npc_1"] = false
	completed_npcs["npc_2"] = false
	completed_npcs["npc_3"] = false
	completed_npcs["npc_4"] = false

	puzzle_completed = false

	if npc_1.has_method("reset_npc"):
		npc_1.reset_npc()

	if npc_2.has_method("reset_npc"):
		npc_2.reset_npc()

	if npc_3.has_method("reset_npc"):
		npc_3.reset_npc()

	if npc_4.has_method("reset_npc"):
		npc_4.reset_npc()

	update_status_label()

	print("Puzzle reset!")
