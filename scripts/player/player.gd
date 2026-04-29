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

@export var line_attack_scene: PackedScene
@export var circle_attack_scene: PackedScene
@export var triangle_attack_scene: PackedScene
@onready var sprite = $AnimatedSprite2D
const WORLD_SCALE = 3.0

const maxSpeed = 120.0 * WORLD_SCALE
const jumpVelocity = -170.0 * WORLD_SCALE
const jumpMultiplier = 0.7
const gravity = 400.0 * WORLD_SCALE

# 1500 2000 800 tight
# 500 600 300 floaty
# 600 800 600 perfect
const acceleration = 800.0 * WORLD_SCALE
const deceleration = 800.0 * WORLD_SCALE
const airAcceleration = 800.0 * WORLD_SCALE

var is_attacking := false
var attack_animations = {
	"line": "line_attack",
	"circle": "circle_attack",
	"triangle": "triangle_attack"
}

var controlling_projectile := false
var current_projectile = null

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

func die():
	reset_room()

func reset_room():
	CoinManager.reset_room_coins()
	get_tree().reload_current_scene()

func _input(event):
	if Input.is_action_just_pressed("reset_room"):
		reset_room()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if controlling_projectile:
		return

	# Handle jump.
	if is_on_floor():
		$CoyoteTimer.start()
	if Input.is_action_just_pressed("jump"):
		$InputBufferTimer.start()
	if not $InputBufferTimer.is_stopped() and not $CoyoteTimer.is_stopped() and not is_attacking:
		velocity.y = jumpVelocity
		$CoyoteTimer.stop()
		$InputBufferTimer.stop()
		
	# Variable jump height.
	if Input.is_action_just_released("jump") and velocity.y < 0 and not is_attacking:
		velocity.y *= jumpMultiplier

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if controlling_projectile:
		velocity.x = 0
	elif not is_attacking:
		var accel = acceleration if is_on_floor() else airAcceleration
		velocity.x = move_toward(velocity.x, direction * maxSpeed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	# Handle attack
	if Input.is_action_just_pressed("line_attack"):
		perform_attack("line")
		
	if Input.is_action_just_pressed("circle_attack"):
		perform_attack("circle")
		
	if Input.is_action_just_pressed("triangle_attack"):
		perform_attack("triangle")
	
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

func _on_hud_line_drawn() -> void:
	print("Signal recieved")
	perform_attack("line")
	
func _on_hud_circle_drawn() -> void:
	print("Signal recieved")
	perform_attack("circle")
	
func _on_hud_triangle_drawn() -> void:
	print("Signal recieved")
	perform_attack("triangle")

func spawn_attack(type: String):
		match type:
			"line":
				spawn_line_attack()
			"circle":
				spawn_circle_attack()
			"triangle":
				spawn_triangle_attack()
	
func spawn_line_attack():
	var attack = line_attack_scene.instantiate()
	get_parent().add_child(attack)
	attack.z_index = 0
	
	attack.scale *= WORLD_SCALE
	attack.global_position.x = $AttackSpawn.global_position.x + 151 if sprite.flip_h else $AttackSpawn.global_position.x - 155
	attack.global_position.y = $AttackSpawn.global_position.y - 60
	
	attack.scale.x *= -1 if sprite.flip_h else 1
	
	attack.attack_finished.connect(_on_line_attack_finished)
	
func _on_line_attack_finished():
	is_attacking = false

func spawn_circle_attack():
	var proj = circle_attack_scene.instantiate()
	get_parent().add_child(proj)
	
	proj.global_position.x = $AttackSpawn.global_position.x + 100 if sprite.flip_h else $AttackSpawn.global_position.x - 100
	proj.global_position.y = $AttackSpawn.global_position.y
	
	var dir = -1 if sprite.flip_h else 1
	proj.set_direction(dir)
	proj.set_player(self)
	
	controlling_projectile = true
	current_projectile = proj
	
	await get_tree().create_timer(2.5).timeout
	end_projectile_control()
	
	if is_instance_valid(proj):
		proj.queue_free()
	
func end_projectile_control():
	controlling_projectile = false
	current_projectile = null
	await get_tree().create_timer(0.2).timeout
	is_attacking = false
	
func spawn_triangle_attack():
	var attack = triangle_attack_scene.instantiate()
	get_parent().add_child(attack)
	attack.z_index = 10
	
	attack.scale *= WORLD_SCALE
	attack.global_position = $AttackSpawn.global_position
	
	attack.scale.x *= -1 if sprite.flip_h else 1

func perform_attack(type: String):
	if is_attacking or not is_on_floor():
		return
	
	is_attacking = true
	
	sprite.play(attack_animations[type])
	await get_tree().process_frame
	spawn_attack(type)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.ends_with("_attack") and sprite.animation != "circle_attack":
		is_attacking = false
		
