extends CharacterBody2D

# HP System Variables
#---------------------------
@export var max_health: int = 5
@export var damage_flash_time: float = 0.15
@export var invincibility_time: float = 0.6

var health: int
var is_invincible := false
var invincibility_timer := 0.0
var flash_timer := 0.0
var is_dead := false
#-----------------------------

@export var attack_scene: PackedScene
@onready var sprite = $AnimatedSprite2D
const WORLD_SCALE = 3.0

const maxSpeed = 120.0 * WORLD_SCALE
const jumpVelocity = -170.0 * WORLD_SCALE
const gravity = 400.0 * WORLD_SCALE

# 1500 2000 800 tight
# 500 600 300 floaty
# 600 800 600 perfect
const acceleration = 600.0 * WORLD_SCALE
const deceleration = 800.0 * WORLD_SCALE
const airAcceleration = 600.0 * WORLD_SCALE

var is_attacking := false

func _ready() -> void:
	health = max_health
	
func take_damage(amount: int) -> void:
	print("player took damage")
	if is_invincible:
		return

	health = max(health - amount, 0)

	# flash red
	sprite.modulate = Color(1, 0.4, 0.4, 1)
	flash_timer = damage_flash_time

	# temporary invincibility
	is_invincible = true
	invincibility_timer = invincibility_time

	if health <= 0:
		queue_free() # or handle death here

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
		
	# Update Timers
	#------------------------------------
	# damage flash timer
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			sprite.modulate = Color(1, 1, 1, 1)

	# invincibility timer
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0.0:
			is_invincible = false
			
	#--------------------------------------
	
	move_and_slide()

func spawn_attack():
	var attack = attack_scene.instantiate()
	add_child(attack)
	attack.scale.x *= WORLD_SCALE
	attack.scale.y *= WORLD_SCALE
	attack.global_position = $AttackSpawn.global_position
	attack.scale.x *= -1 if sprite.flip_h else 1

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false


func _on_canvas_triangle_drawn() -> void:
	spawn_attack()
