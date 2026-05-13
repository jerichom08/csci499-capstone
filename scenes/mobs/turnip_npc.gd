extends Area2D

@export var interact_action : String = "interaction"
@export var npc_text : String = "Hello there."

var player_in_range : bool = false

@onready var interaction_label = $InteractionLabel2
@onready var dialogue_label = $DialogueLabel
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_label:
		interaction_label.visible = false

	if dialogue_label:
		dialogue_label.visible = false

	if animated_sprite:
		animated_sprite.play("idle")


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed(interact_action):
		_interact_with_npc()


func _interact_with_npc() -> void:
	if dialogue_label:
		dialogue_label.text = npc_text
		dialogue_label.visible = true

	if animated_sprite:
		animated_sprite.play("talk")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		if interaction_label:
			interaction_label.visible = true

		if animated_sprite:
			animated_sprite.play("idle")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_label:
			interaction_label.visible = false

		if dialogue_label:
			dialogue_label.visible = false

		if animated_sprite:
			animated_sprite.play("idle")

func set_npc_text(new_text: String, show_now: bool = false) -> void:
	npc_text = new_text

	if show_now and dialogue_label:
		dialogue_label.text = npc_text
		dialogue_label.visible = true
