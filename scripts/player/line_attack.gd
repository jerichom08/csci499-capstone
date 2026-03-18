extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Area2D/CollisionShape2D

signal attack_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.disabled = true
	sprite.play("attack")
	sprite.animation_finished.connect(_on_animation_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_animation_finished():
	attack_finished.emit()
	queue_free()

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "attack":
		hitbox.disabled = sprite.frame < 1 or sprite.frame > 4
