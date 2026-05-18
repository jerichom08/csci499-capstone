extends CharacterBody2D

# HP System Variables
#---------------------------
@export var damage_flash_time: float = 0.15
@export var invincibility_time: float = 1

var is_invincible := false
var invincibility_timer := 0.0
var flash_timer := 0.0
var is_dead := false

#-----------------------------

@export var line_attack_scene: PackedScene
@export var circle_attack_scene: PackedScene
@export var triangle_attack_scene: PackedScene
@onready var sprite = $AnimatedSprite2D
@onready var line_attack_sfx = $LineAttackSFX
@onready var circle_attack_sfx = $CircleAttackSFX
@onready var triangle_attack_sfx = $TriangleAttackSFX
const WORLD_SCALE = 3.0

#----------inventory line--------
@onready var held_item_sprite: Sprite2D = $ItemHolder/HeldItemSprite


const maxSpeed = 120.0 * WORLD_SCALE
const jumpVelocity = -170.0 * WORLD_SCALE
const jumpMultiplier = 0.7
const gravity = 400.0 * WORLD_SCALE
var facingDirection = 1

const enemyLayer = 10
const enemyHurtboxLayer = 4
var normalCollisionMask = 0
var normalHurtboxMask = 0
const dashSpeed = 450 * WORLD_SCALE
const dashTime = 0.15
const dashCooldown = 0.4
const dashInvincibilityTime = 0.2

@export var dashEnabled: bool = false
var isDashing = false
var dashTimer = 0.0
var dashCooldownTimer = 0.0
var dashDirection = 1

const oneWayPlatformLayer = 5
const dropThroughTime = 0.2
var droppingThrough := false

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

#--------inventory--------
var inventory: Array[Dictionary] = []
var selected_item_index: int = -1
var current_item_name: String = ""

func _ready() -> void:
	PlayerStats.health_changed.emit(PlayerStats.health, PlayerStats.max_health)
	
	if held_item_sprite:
		held_item_sprite.visible = false
	
	normalCollisionMask = collision_mask
	normalHurtboxMask = $Hurtbox.collision_mask
		
func take_damage(amount: int, knockback: Vector2) -> void:
	#print("player took damage")

	if is_invincible:
		return
	
	if is_dead:
		return

	PlayerStats.take_damage(amount)

	velocity = knockback

	# flash red
	sprite.modulate = Color(1, 0.4, 0.4, 1)
	flash_timer = damage_flash_time

	# invincibility
	is_invincible = true
	invincibility_timer = invincibility_time

	if PlayerStats.health <= 0:
		die()

func heal(amount: int = 2):
	if is_dead:
		return
	
	PlayerStats.heal(amount)

func die():
	if is_dead:
		return
	is_dead = true
	print("You're dead")
	reset_room()

func reset_room():
	PlayerStats.reset_health()
	CoinManager.reset_room_coins()
	get_tree().reload_current_scene()

#func _input(event):
	#if Input.is_action_just_pressed("reset_room"):
		#reset_room()

func _physics_process(delta: float) -> void:
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
			
	# dash timer
	if dashCooldownTimer > 0:
		dashCooldownTimer -= delta
			
	#--------------------------------------
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# dash movement
	if isDashing:
		dashTimer -= delta
		velocity.y = 0
		velocity.x = dashDirection * dashSpeed
		move_and_slide()
		
		if dashTimer <= 0:
			isDashing = false
		return
	
	if dashEnabled and Input.is_action_just_pressed("move_down") and is_on_floor() and !is_attacking:
		drop_through_platform()
	
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
	
	if direction != 0:
		facingDirection = sign(direction)
		
	if Input.is_action_just_pressed("dash") and dashCooldownTimer <= 0 and not is_attacking and not controlling_projectile:
		start_dash()
	
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
		
	move_and_slide()
		
func start_dash():
	isDashing = true
	dashTimer = dashTime
	dashCooldownTimer = dashCooldown
	
	dashDirection = facingDirection
	if dashDirection == 0:
		dashDirection = 1
		
	is_invincible = true
	invincibility_timer = dashInvincibilityTime
	sprite.play("run")
	
	collision_mask &= ~(1 << (enemyLayer - 1))
	collision_layer = 0
	$Hurtbox.collision_mask &= ~(1 << (enemyHurtboxLayer - 1))
	await get_tree().create_timer(dashInvincibilityTime).timeout
	if not is_inside_tree():
		return
	collision_mask |= (1 << (enemyLayer - 1))
	$Hurtbox.collision_mask |= (1 << (enemyHurtboxLayer - 1))
	collision_layer = 1

func drop_through_platform() -> void:
	if droppingThrough:
		return
		
	droppingThrough = true
		
	collision_mask &= ~(1 << (oneWayPlatformLayer - 1))
	await get_tree().create_timer(dropThroughTime).timeout
	collision_mask |= (1 << (oneWayPlatformLayer - 1))
	
	droppingThrough = false

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
				line_attack_sfx.play()
				spawn_line_attack()
			"circle":
				circle_attack_sfx.play()
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
	
	await create_tween().tween_interval(0.3).finished
	triangle_attack_sfx.play()

func perform_attack(type: String):
	if is_attacking or not is_on_floor() or isDashing:
		return
	
	is_attacking = true
	
	sprite.play(attack_animations[type])
	await get_tree().process_frame
	spawn_attack(type)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.ends_with("_attack") and sprite.animation != "circle_attack":
		is_attacking = false
		
# ---------------Below implemntation of inventory system---------------------
func add_item(item_name: String, item_texture: Texture2D) -> void:
	var item = {
		"name": item_name,
		"texture": item_texture
	}

	inventory.append(item)
	selected_item_index = inventory.size() - 1
	select_item(selected_item_index)


func select_item(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return

	selected_item_index = index

	var item = inventory[selected_item_index]
	hold_item(item["name"], item["texture"])

func hold_item(item_name: String, item_texture: Texture2D) -> void:
	current_item_name = item_name

	if held_item_sprite:
		held_item_sprite.texture = item_texture
		held_item_sprite.visible = true
		held_item_sprite.show()
		held_item_sprite.z_index = 999
		held_item_sprite.z_as_relative = false
		held_item_sprite.global_position = global_position + Vector2(0, -100)
		held_item_sprite.scale = Vector2(0.025, 0.025)
		held_item_sprite.modulate = Color(1, 1, 1, 1)


func clear_held_item() -> void:
	current_item_name = ""

	if held_item_sprite:
		held_item_sprite.texture = null
		held_item_sprite.visible = false


func remove_selected_item() -> void:
	if selected_item_index == -1:
		return

	inventory.remove_at(selected_item_index)

	if inventory.size() == 0:
		selected_item_index = -1
		clear_held_item()
	else:
		selected_item_index = clamp(selected_item_index, 0, inventory.size() - 1)
		select_item(selected_item_index)
		
		
		
func remove_last_items(amount: int) -> void:
	for i in range(amount):
		if inventory.size() > 0:
			inventory.pop_back()

	if inventory.size() == 0:
		selected_item_index = -1
		clear_held_item()
	else:
		selected_item_index = inventory.size() - 1
		select_item(selected_item_index)
