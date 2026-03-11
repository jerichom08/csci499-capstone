extends Node2D

@export var force = -600.0
@export var release_delay := 0.2  
@onready var sprite = $Sprite2D  

var release_timer := 0.0
var player_on_pad := false

func _ready():
	sprite.frame = 0

func _process(delta: float) -> void:
	if not player_on_pad and release_timer > 0:
		release_timer -= delta
		if release_timer <= 0:
			sprite.frame = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_on_pad = true
	sprite.frame = 1
	if body is CharacterBody2D:
		body.velocity.y = force

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_on_pad = false
	release_timer = release_delay  
