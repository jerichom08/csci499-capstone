extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	hitbox.disabled = true
	sprite.play("tongue")
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_animated_sprite_2d_frame_changed)

func _on_animation_finished() -> void:
	queue_free()

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "tongue":
		hitbox.disabled = sprite.frame < 1
