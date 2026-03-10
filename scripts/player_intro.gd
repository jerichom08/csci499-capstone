extends CharacterBody2D


const speed = 400.0
@onready var sprite = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed

	move_and_slide()
	update_animation(direction)

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("run")
		
		if direction.x != 0:
			sprite.flip_h = direction.x < 0	
