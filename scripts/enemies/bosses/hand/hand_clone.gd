extends CharacterBody2D

var despawning := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 900.0 * delta

	move_and_slide()

func take_damage(_damage : int, _knockback : Vector2 = Vector2.ZERO) -> void:
	despawn()

func despawn() -> void:
	if despawning:
		return

	despawning = true

	var sprite : AnimatedSprite2D = $AnimatedSprite2D

	var tween := create_tween()

	tween.tween_property(
		sprite,
		"modulate:a",
		0.0,
		0.1
	)

	tween.tween_callback(queue_free)
