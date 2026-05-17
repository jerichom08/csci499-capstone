extends Node2D


@onready var cauldron: AnimatedSprite2D = $cauldron

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$cauldron_work.play("default")
