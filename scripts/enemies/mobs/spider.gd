"""
Spider
├─CollisionShape2D 
├─AnimatedSprite2D 
├─Hurtbox
├─Hitbox
├─VisionRay
├─LedgeRay
└─PlayerDetectionZone
"""

extends EnemyBase

@onready var pdz = $PlayerDetectionZone

var WORLD_SCALE : float = 3.0
var dropping : bool = false

func _ready() -> void:
	super._ready()
	
	scale *= WORLD_SCALE
	
	# --- Ray Setup ---
	if vision_ray:
		vision_ray.target_position = Vector2(30, 0)
	
	if ledge_ray:
		ledge_ray.position = Vector2(5, 1)
		ledge_ray.target_position = Vector2(0, 20)
	
	if hitbox:
		hitbox.monitoring = false
	
	sprite.frame_changed.connect(_on_animated_sprite_2d_frame_changed)
	
	set_state(State.REST)


func _physics_process(delta: float) -> void:
	if dropping:
		velocity.y = stats.gravity
	
	update_state_machine()
	move_and_slide()


func idle() -> void:
	if is_on_floor():
		dropping = false
		set_state(State.CHASE)


func rest() -> void:
	velocity = Vector2.ZERO
	
	if pdz.player and can_see_player_los(pdz.player):
		dropping = true
		set_state(State.IDLE)


func return_to_spawn() -> void:
	velocity.x = 0
	
	# --- MOVE BACK TO ORIGINAL X POSITION ---
	var dx : float = abs(global_position.x - spawn_position.x)
	
	if dx > 5:
		var dir : int = sign(spawn_position.x - global_position.x)
		
		face_direction(-dir)
		velocity.x = dir * stats.move_speed
		return
	
	# --- CLIMB BACK UP ---
	if global_position.y > spawn_position.y:
		sprite.play("idle")
		velocity.y = -stats.move_speed
		return
	
	# --- FINISHED RETURNING ---
	global_position = spawn_position
	velocity = Vector2.ZERO
	dropping = false
	set_state(State.REST)


func chase() -> void:
	var player = pdz.player
	
	if player == null:
		set_state(State.RETURN)
		return
	
	if not can_see_player_los(player):
		set_state(State.RETURN)
		return
	
	var dx : float = abs(player.global_position.x - global_position.x)
	
	# --- ATTACK ---
	if dx <= 40:
		set_attack(AttackType.DEFAULT)
		set_state(State.ATTACK)
		return
	
	var direction : Vector2 = global_position.direction_to(player.global_position)
	
	if direction.x != 0:
		face_direction(-sign(direction.x))
	
	if should_turn_around():
		face_direction(-facing_direction)
		velocity.x = facing_direction * stats.move_speed
	else:
		velocity.x = direction.x * stats.move_speed


func attack() -> void:
	velocity.x = 0
	
	var player = pdz.player
	
	if player == null:
		set_state(State.RETURN)
		return
	
	face_direction(-sign(player.global_position.x - global_position.x))


func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 0.4)


func fade_out_and_free() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func take_damage(damage: int, knockback: Vector2) -> void:
	set_state(State.DEFEAT)


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.DEFEAT:
		queue_free()
	
	elif current_state == State.ATTACK:
		set_state(State.CHASE)


func _on_animated_sprite_2d_frame_changed() -> void:
	if hitbox == null:
		return
	
	if current_state != State.ATTACK:
		hitbox.monitoring = false
		return
	
	if sprite.frame >= 4 and sprite.frame <= 6:
		hitbox.monitoring = true
	else:
		hitbox.monitoring = false


func can_see_player_los(player: Node2D) -> bool:
	if player == null:
		return false
	
	vision_ray.target_position = to_local(player.global_position)
	vision_ray.force_raycast_update()
	
	if not vision_ray.is_colliding():
		return false
	
	return vision_ray.get_collider() == player


func should_turn_around() -> bool:
	return is_about_to_walk_off_ledge()


func face_direction(direction: int) -> void:
	if direction == 0:
		return
	
	if facing_direction != direction:
		facing_direction = direction
		
		sprite.flip_h = facing_direction < 0  
	
	# Update Attack Spawns
	if light_spawn:
		light_spawn.position.x = abs(light_spawn.position.x) * facing_direction
	
	if heavy_spawn:
		heavy_spawn.position.x = abs(heavy_spawn.position.x) * facing_direction
	
	# Update rays
	if vision_ray:
		vision_ray.target_position.x = abs(vision_ray.target_position.x) * facing_direction
	
	if wall_ray:
		wall_ray.target_position.x = abs(wall_ray.target_position.x) * facing_direction
	
	# --- Spider Ledge Ray ---
	if ledge_ray:
		ledge_ray.position = Vector2(5 * facing_direction, 1)
		ledge_ray.target_position = Vector2(0, 20)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
