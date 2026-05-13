"""
Bat
├─CollisionShape2D 
├─AnimatedSprite2D 
├─Hurtbox 
├─Hitbox
└─VisionRay
"""

extends EnemyBase

#@onready var pdz = $PlayerDetectionZone
@export var detection_radius : float = 78.0

@onready var detection_shape : CollisionShape2D = $PlayerDetectionZone/CollisionShape2D

func _ready() -> void:
	super._ready()
	set_state(State.REST)
	detection_shape.shape = detection_shape.shape.duplicate()
	var circle := detection_shape.shape as CircleShape2D
	if circle:
		circle.radius = detection_radius
	
func _physics_process(delta: float) -> void:
	update_state_machine()
	move_and_slide()

func rest() -> void:
	if pdz.player and can_see_player_los(pdz.player):
		set_state(State.CHASE)

func return_to_spawn() -> void:
	if current_state == State.DEFEAT:
		return
	if global_position.distance_to(spawn_position) < 5:
		velocity = Vector2.ZERO
		set_state(State.REST)
		return
	
	var direction : Vector2 = global_position.direction_to(spawn_position)
	velocity = direction * stats.move_speed
	face_direction(-sign(direction.x))

func chase() -> void:
	#set_state(State.CHASE)
	
	var player = pdz.player
	if player == null:
		return_to_spawn()
		return
	
	var direction : Vector2 = global_position.direction_to(player.global_position)
	
	if direction.x != 0:
		face_direction(-sign(direction.x))
	
	if should_turn_around():
		velocity = Vector2.ZERO
	else:
		velocity = direction * stats.move_speed

func take_damage(damage : int, knockback : Vector2 = Vector2.ZERO) -> void:
	set_state(State.DEFEAT)


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.DEFEAT:
		queue_free()

func can_see_player_los(player: Node2D) -> bool:
	if player == null:
		return false
	
	vision_ray.target_position = to_local(player.global_position)
	vision_ray.force_raycast_update()
	
	if not vision_ray.is_colliding():
		return false
	
	print(vision_ray.get_collider())
	
	return vision_ray.get_collider() == player
