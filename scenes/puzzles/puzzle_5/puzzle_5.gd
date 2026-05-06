extends Node2D

signal puzzle_completed

@export var correct_sequence: Array[String] = ["top", "middle", "bottom"]

var current_step: int = 0
var puzzle_done: bool = false

@onready var spawn_point = $SpawnPoint
@onready var message_label = $MessageLabel
@onready var exit_door = $ExitDoor
@onready var section_entry_points = {
	0: $SpawnPoint,
	1: $Section2/EntryPoint,
	2: $Section3/EntryPoint
}

@onready var path_areas = {
	$Section1/TopPath: "top",
	$Section1/MiddlePath: "middle",
	$Section1/BottomPath: "bottom",

	$Section2/TopPath: "top",
	$Section2/MiddlePath: "middle",
	$Section2/BottomPath: "bottom",

	$Section3/TopPath: "top",
	$Section3/MiddlePath: "middle",
	$Section3/BottomPath: "bottom"
}

func _ready() -> void:
	if message_label:
		message_label.visible = false
	if exit_door:
		exit_door.visible = false
		exit_door.monitoring = false
		
	for area in path_areas.keys():
		if area and area is Area2D:
			area.monitoring = true
			area.body_entered.connect(_on_path_body_entered.bind(path_areas[area]))
		
func _on_path_body_entered(body: Node2D, path_name: String) -> void:
	if puzzle_done:
		return

	if not body.is_in_group("player"):
		return

	choose_path(path_name, body)

func choose_path(path_name: String, player: Node2D) -> void:
	print("choose_path called with:", path_name)

	if puzzle_done:
		return

	if path_name == correct_sequence[current_step]:
		current_step += 1
		show_message("Correct path...")

		if current_step >= correct_sequence.size():
			puzzle_done = true
			show_message("Puzzle complete!")
			unlock_exit()
			emit_signal("puzzle_completed")
		else:
			move_player_to_section(player, current_step)
	else:
		show_message("Wrong path... the hallway loops.")
		reset_puzzle(player)

func reset_puzzle(player: Node2D) -> void:
	current_step = 0
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func move_player_to_section(player: Node2D, section_index: int) -> void:
	if player and section_entry_points.has(section_index):
		player.global_position = section_entry_points[section_index].global_position

func unlock_exit() -> void:
	if exit_door:
		exit_door.visible = true
		exit_door.monitoring = true

func show_message(text: String) -> void:
	if not message_label:
		return

	message_label.text = text
	message_label.visible = true

	var timer := get_tree().create_timer(1.2)
	timer.timeout.connect(func():
		if message_label:
			message_label.visible = false
	)
