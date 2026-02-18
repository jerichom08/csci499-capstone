extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const GRAVITY = 400.0

@onready var sprite = $AnimatedSprite2D
var is_attacking := false
var attack_offset := 32


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		start_attack()
	
	# Animation
	if is_attacking:
		pass
	elif direction == 0:
		sprite.play("idle")
	else:
		sprite.play("run")
	if direction != 0:
		sprite.flip_h = direction < 0
		
	move_and_slide()

func start_attack():
	is_attacking = true
	sprite.play("attack")
	if sprite.flip_h:
		sprite.offset.x = -attack_offset
	else:
		sprite.offset.x = attack_offset


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
		sprite.offset.x = 0
