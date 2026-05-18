extends Node2D

@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	hitbox.disabled = false

	await get_tree().create_timer(0.05).timeout

	hitbox.disabled = true

	await get_tree().create_timer(0.05).timeout

	queue_free()
