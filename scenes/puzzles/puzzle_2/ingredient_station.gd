extends Area2D

signal ingredient_selected(ingredient_name)

@export var ingredient_name : String = "bread"
@export var interact_action : String = "interact"
@export var show_debug_prints : bool = true

var player_in_range : bool = false

@onready var interaction_label = $InteractionLabel
@onready var audio_player = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.visable = false
		
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed(interact_action):
		_handle_interaction()
		
func _handle_interaction() -> void:
	if show_debug_prints:
		print("Ingredient selected: ", ingredient_name)
		
	if audio_player and audio_player.stream:
		audio_player.play()
	emit_signal("ingredient_selected", ingredient_name)
	
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true;
		
	if interaction_label:
		interaction_label.visable = true
		
func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false
		
		if interaction_label:
			interaction_label.visable = false
