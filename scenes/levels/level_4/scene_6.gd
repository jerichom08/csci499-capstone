extends Node2D

@onready var interact: Area2D = $interact

@onready var interaction_label: Label = $interract/InteractionLabel


@onready var cauldron = $c/cauldron
@onready var cauldron_work: AnimatedSprite2D = $cauldron_work


var player_in_range := false

func _ready() -> void:
	interaction_label.visible = false
	
	cauldron.visible = true
	cauldron_work.visible = false

	interact.body_entered.connect(_on_body_entered)
	interact.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		cauldron.visible = false
		cauldron_work.visible = true
		cauldron_work.play("default")
		
		interaction_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		interaction_label.visible = true
		interaction_label.text = "Press E to interact"

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		interaction_label.visible = false
