extends Node2D

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("attack")
	sprite.animation_finished.connect(_on_animation_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_animation_finished():
	queue_free()
