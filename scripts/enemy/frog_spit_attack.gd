extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	hitbox.disabled = false
	sprite.play("spit")
	sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	queue_free()

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "spit":
		hitbox.disabled = sprite.frame > 3
