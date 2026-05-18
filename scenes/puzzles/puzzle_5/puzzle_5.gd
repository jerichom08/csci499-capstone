extends Node2D

signal puzzle_completed

@export var correct_sequence: Array[String] = ["top", "middle", "bottom"]

var chosen_sequence: Array[String] = []
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
	$Section1/TopPath: {"section": 0, "path": "top"},
	$Section1/MiddlePath: {"section": 0, "path": "middle"},
	$Section1/BottomPath: {"section": 0, "path": "bottom"},

	$Section2/TopPath: {"section": 1, "path": "top"},
	$Section2/MiddlePath: {"section": 1, "path": "middle"},
	$Section2/BottomPath: {"section": 1, "path": "bottom"},

	$Section3/TopPath: {"section": 2, "path": "top"},
	$Section3/MiddlePath: {"section": 2, "path": "middle"},
	$Section3/BottomPath: {"section": 2, "path": "bottom"}
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
		
func _on_path_body_entered(body: Node2D, path_data: Dictionary) -> void:
	if puzzle_done:
		return

	if not body.is_in_group("player"):
		return

	choose_path(path_data["section"], path_data["path"], body)
	
func choose_path(section_index: int, path_name: String, player: Node2D) -> void:
	print("Section:", section_index, " Path chosen:", path_name)

	if puzzle_done:
		return

	chosen_sequence.append(path_name)

	if section_index < 2:
		show_message("You continue through the hallway...")
		return

	if chosen_sequence == correct_sequence:
		puzzle_done = true
		show_message("Puzzle complete!")
		unlock_exit()
		emit_signal("puzzle_completed")
	else:
		show_message("Wrong path... the hallway loops.")
		reset_puzzle(player)

func reset_puzzle(player: Node2D) -> void:
	chosen_sequence.clear()

	if player and spawn_point:
		var camera := player.get_node_or_null("Camera2D")

		var saved_velocity := Vector2.ZERO
		if "velocity" in player:
			saved_velocity = player.velocity

		if camera:
			camera.position_smoothing_enabled = false

		player.global_position = spawn_point.global_position

		if "velocity" in player:
			player.velocity = saved_velocity

		await get_tree().process_frame

		if camera:
			camera.force_update_scroll()
			camera.position_smoothing_enabled = true

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
