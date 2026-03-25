extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox/CollisionShape2D

func _ready() -> void:
	hitbox.disabled = true
	sprite.play("attack")
	sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	queue_free()

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "attack":
		hitbox.disabled = sprite.frame < 5
