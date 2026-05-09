extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

signal finished

func play_hole() -> void:
	sprite.play("hole")

func _ready() -> void:
	scale *= 3
	sprite.animation_finished.connect(_on_finished)

func _on_finished() -> void:
	finished.emit()
	queue_free()
