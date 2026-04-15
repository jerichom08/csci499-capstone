extends Node2D

@onready var npc_1 = $NPC_1
@onready var npc_2 = $NPC_2
@onready var npc_3 = $NPC_3
@onready var npc_4 = $NPC_4
@onready var puzzle_status_label = $PuzzleStatusLabel

var completed_npcs : Dictionary = {
	"npc_1": false,
	"npc_2": false,
	"npc_3": false,
	"npc_4": false
}

var puzzle_completed : bool = false


func _ready() -> void:
	connect_npc(npc_1, "NPC_1")
	connect_npc(npc_2, "NPC_2")
	connect_npc(npc_3, "NPC_3")
	connect_npc(npc_4, "NPC_4")

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


func update_status_label() -> void:
	var total_done := 0

	for npc_id in completed_npcs.keys():
		if completed_npcs[npc_id]:
			total_done += 1

	if puzzle_status_label and not puzzle_completed:
		puzzle_status_label.text = "Talked to %d / 4 NPCs" % total_done
