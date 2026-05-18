"""
Skeleton
├─CollisionShape2D 
├─AnimatedSprite2D 
├─Hurtbox 
├─Hitbox
├─PlayerDetectionZone
├─VisionRay
└─LedgeRay
"""

extends EnemyBase

var seen_animations: Array[String] = []
var ledge_offset_x : float
var is_arising : bool = false
var defeat_sfx_played: bool = false

@onready var skeleton_defeat_sfx : AudioStreamPlayer2D = $Defeat
@onready var skeleton_arise_sfx : AudioStreamPlayer2D = $Arise
@onready var skeleton_chase_sfx : AudioStreamPlayer2D = $Chase



func _ready() -> void:
	ledge_offset_x = ledge_ray.position.x
	#scale *= 3
	set_state(State.REST)
	super._ready()

func _physics_process(_delta: float) -> void:
	if not seen_animations.has(sprite.animation):
		print(sprite.animation)
		seen_animations.append(sprite.animation)
	if not is_on_floor():
		velocity.y += stats.gravity * _delta
	update_state_machine()
	move_and_slide()

func idle() -> void:
	if skeleton_chase_sfx.playing:
		skeleton_chase_sfx.stop()
	velocity.x = 0
	if pdz.player and can_see_player_los(pdz.player):
		set_state(State.CHASE)

func rest() -> void:
	set_collisions_enabled(false)
	velocity.x = 0

	if skeleton_chase_sfx.playing:
		skeleton_chase_sfx.stop()

	if is_arising:
		return

	if pdz.player and can_see_player_los(pdz.player):
		is_arising = true

		skeleton_arise_sfx.play()
		await skeleton_arise_sfx.finished
		set_state(State.ARISE)

func arise() -> void:
	velocity.x = 0 
	
func chase() -> void:
	if not skeleton_chase_sfx.playing:
		skeleton_chase_sfx.play()

	var player = pdz.player

	if player == null:
		set_state(State.IDLE)
		return

	var direction := global_position.direction_to(
		player.global_position
	)

	var move_dir :int = sign(direction.x)

	# Always visually face the player
	face_direction(-move_dir)

	# Stop movement if path ahead is unsafe
	if should_turn_around():
		velocity.x = 0
		return

	velocity.x = move_dir * stats.move_speed
	
func take_damage(_damage : int, _knockback: Vector2 = Vector2.ZERO) -> void:
	if skeleton_chase_sfx.playing:
		skeleton_chase_sfx.stop()
	velocity.x = 0
	set_collisions_enabled(false)
	if !defeat_sfx_played:
		skeleton_defeat_sfx.play()
		defeat_sfx_played = true
	set_state(State.DEFEAT)
	
func can_see_player_los(player: Node2D) -> bool:
	if player == null:
		return false
	
	vision_ray.target_position = to_local(player.global_position)
	vision_ray.force_raycast_update()
	
	if not vision_ray.is_colliding():
		return false
	
	return vision_ray.get_collider() == player

func _on_animation_finished() -> void:
	match current_state:
		State.ARISE:
			set_collisions_enabled(true)
			set_state(State.CHASE)
			
		State.DEFEAT:
			await get_tree().create_timer(2.0).timeout
			is_arising = false
			defeat_sfx_played = false
			set_collisions_enabled(true)
			set_state(State.REST)

func face_direction(direction: int) -> void:
	super.face_direction(direction)

	if ledge_ray:
		ledge_ray.position.x = ledge_offset_x * -direction
	
func set_collisions_enabled(enabled: bool) -> void:
	if hurtbox:
		hurtbox.set_deferred("monitoring", enabled)
		hurtbox.set_deferred("monitorable", enabled)

	if hitbox:
		hitbox.set_deferred("monitoring", enabled)
		hitbox.set_deferred("monitorable", enabled)
