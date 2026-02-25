extends CharacterBody2D

@export var attack_scene: PackedScene

const maxSpeed = 150.0
const jumpVelocity = -200.0
const gravity = 400.0

# 1500 2000 800 tight
# 500 600 300 floaty
# 600 800 600 perfect
const acceleration = 600.0
const deceleration = 800.0
const airAcceleration = 600.0

@onready var sprite = $AnimatedSprite2D
var is_attacking := false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if not is_attacking:
		var accel = acceleration if is_on_floor() else airAcceleration
		velocity.x = move_toward(velocity.x, direction * maxSpeed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		spawn_attack()
		is_attacking = true
		sprite.play("attack")
	
	# Animation
	if is_attacking:
		pass
	elif direction == 0:
		sprite.play("idle")
	else:
		sprite.play("run")
	if direction != 0 and not is_attacking:
		sprite.flip_h = direction < 0
		$AttackSpawn.position.x = abs($AttackSpawn.position.x) * (-1 if sprite.flip_h else 1)
		
	move_and_slide()

func spawn_attack():
	var attack = attack_scene.instantiate()
	add_child(attack)
	attack.global_position = $AttackSpawn.global_position
	attack.scale.x = -1 if sprite.flip_h else 1

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
