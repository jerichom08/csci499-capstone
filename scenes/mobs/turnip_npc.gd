extends Area2D

signal npc_interacted

@export var npc_text: String = "Hello traveler! Bring me the items in the correct order."
@export var dialogue_time: float = 1.5
@export var interact_action : String = "interaction"
@export var character_face : Texture2D
@export var dialogue_box_path : NodePath

var player_in_range : bool = false
var dialogue_open: bool = false

@onready var interaction_label = $InteractionLabel2
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_box = get_node_or_null(dialogue_box_path)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_label:
		interaction_label.visible = false

	if dialogue_box:
		dialogue_box.hide_dialogue()

	if animated_sprite:
		animated_sprite.play("idle")


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed(interact_action):
		if dialogue_open:
			if dialogue_box:
				dialogue_box.hide_dialogue()
			dialogue_open = false
		else:
			_interact_with_npc()


func _interact_with_npc() -> void:
	if _player_has_less_than_required_items():
		show_temporary_text(npc_text)
		return

	npc_interacted.emit()

	if animated_sprite:
		animated_sprite.play("idle")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		if interaction_label:
			interaction_label.visible = true

		if animated_sprite:
			animated_sprite.play("idle")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		dialogue_open = false
		player_in_range = false

		if interaction_label:
			interaction_label.visible = false

		if dialogue_box:
			dialogue_box.hide_dialogue()

		if animated_sprite:
			animated_sprite.play("idle")


func set_npc_text(new_text: String, show_now: bool = false) -> void:
	npc_text = new_text

	if show_now:
		show_temporary_text(npc_text)


func show_temporary_text(temp_text: String) -> void:
	if dialogue_box:
		dialogue_box.show_dialogue(character_face, temp_text)
		dialogue_open = true


func _player_has_less_than_required_items() -> bool:
	var level = get_parent()

	if level and "picked_up_order" in level and "correct_order" in level:
		return level.picked_up_order.size() < level.correct_order.size()

	return false
