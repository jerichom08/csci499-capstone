@tool
extends CharacterBody2D
@export var stats: Stats
@export var move_speed: float = 70.0
@export var stop_distance: float = 150.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var vision_ray: RayCast2D = $VisionRay
@export var vision_ray_target: Vector2 = Vector2(75, 75)
@export_tool_button("Flip Vision Ray (X)")
var flip_vision_ray_button := _flip_vision_ray
@onready var wall_ray: RayCast2D = $WallRay

var has_detected_player := false
var target_player: Node2D = null
var is_dead : bool = false

func _ready() -> void:
	vision_ray.target_position = vision_ray_target
	sprite.play("rest")
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not has_detected_player:
		check_for_player()
		velocity = Vector2.ZERO
	else:
		if is_instance_valid(target_player):
			move_toward_player()
		else:
			velocity = Vector2.ZERO

	move_and_slide()

func check_for_player() -> void:
	if vision_ray.is_colliding():
		var collider = vision_ray.get_collider()

		if collider and collider.is_in_group("player"):
			has_detected_player = true
			target_player = collider as Node2D
			sprite.play("idle")

func move_toward_player() -> void:
	var to_player = target_player.global_position - global_position
	var distance = to_player.length()

	if distance == 0:
		velocity = Vector2.ZERO
		return

	if distance <= stop_distance:
		var away_from_player = (-to_player).normalized()
		velocity = away_from_player * move_speed * 0.5
		return

	var direction_to_player = to_player.normalized()
	var desired_velocity = direction_to_player * move_speed

	if wall_ray.is_colliding():
		if sign(desired_velocity.x) == sign(wall_ray.target_position.x):
			desired_velocity.x = 0

	velocity = desired_velocity

	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

func handle_wall_turn() -> void:
	if wall_ray.is_colliding():
		velocity.x *= -1
		wall_ray.target_position.x *= -1
		vision_ray.target_position.x *= -1
		
func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	die()
	
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO

	# disable interactions
	if hurtbox:
		hurtbox.monitoring = false
		hurtbox.monitorable = false

	if vision_ray:
		vision_ray.enabled = false

	if wall_ray:
		wall_ray.enabled = false

	sprite.play("death")
	
func _on_animation_finished() -> void:
	if is_dead and sprite.animation == "death":
		queue_free()  # OR: visible = false
		
func _flip_vision_ray() -> void:
	vision_ray_target.x = -vision_ray_target.x
	vision_ray.target_position = vision_ray_target

	if Engine.is_editor_hint():
		notify_property_list_changed()
