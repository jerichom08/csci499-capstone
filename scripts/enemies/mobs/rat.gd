extends EnemyBase

const WORLD_LEFT   : float = 0.0
const WORLD_RIGHT  : float = 1400.0
const WORLD_TOP    : float = 0.0   
const WORLD_BOTTOM : float = 720.0

@export var chase_speed : float = 350.0
@export var chase_duration : float = 1.5
@export var underground_wait : float = 1.0
@export var patrol_radius : float = 250.0
@export var player_offset : float = 25.0
@export var hole_delay : float = 0.5

@onready var rat_hit: AudioStreamPlayer2D = $RatHit
@onready var rat_attack: AudioStreamPlayer2D = $RatAttack
@onready var rat_idle: AudioStreamPlayer2D = $RatIdle
@onready var rat_emerge: AudioStreamPlayer2D = $RatEmerge

@export var hole_scene : PackedScene

@onready var pdz = $PlayerDetectionZone

var disappearing := false
var active := false
var cycle_started := false

var base_position : Vector2
var next_spawn_position : Vector2

func _ready() -> void:
	super._ready()

	scale *= 3

	base_position = global_position
	next_spawn_position = base_position

	set_state(State.REST)

	# start hidden
	sprite.modulate.a = 0.0

	set_collisions_enabled(false)

func _process(_delta: float) -> void:
	print(pdz.player)
	if cycle_started:
		return

	if pdz.player != null:
		cycle_started = true
		start_cycle()

func _physics_process(_delta: float) -> void:
	update_state_machine()
	move_and_slide()
	apply_world_bounds()

func rest() -> void:
	velocity = Vector2.ZERO

func chase() -> void:
	if disappearing:
		return
	
	if !rat_idle.playing:
		rat_idle.play()
	
	var player := get_player()

	if player == null:
		velocity.x = 0
		return

	var target_x : float

	if global_position.x < player.global_position.x:
		target_x = player.global_position.x - player_offset
	else:
		target_x = player.global_position.x + player_offset

	target_x = clamp(
		target_x,
		base_position.x - patrol_radius,
		base_position.x + patrol_radius
	)

	var dir : int = sign(target_x - global_position.x)

	face_direction(dir)

	velocity.x = dir * chase_speed

	if abs(global_position.x - target_x) <= 10:
		velocity.x = 0

func start_cycle() -> void:
	while current_state != State.DEFEAT and pdz.player != null:
		await get_tree().create_timer(underground_wait).timeout

		if current_state == State.DEFEAT:
			return

		var spawn_x := randf_range(
			base_position.x - patrol_radius,
			base_position.x + patrol_radius
		)

		next_spawn_position = Vector2(
			spawn_x,
			base_position.y
		)
		rat_emerge.play()
		await rat_emerge.finished
		spawn_hole(next_spawn_position, "open")

		await get_tree().create_timer(hole_delay).timeout

		if current_state == State.DEFEAT:
			return


		spawn_rat()

		await get_tree().create_timer(chase_duration).timeout

		if current_state == State.DEFEAT:
			return

		await despawn_rat()
	cycle_started = false

func spawn_rat() -> void:

	active = true
	disappearing = false

	global_position = next_spawn_position

	sprite.modulate.a = 1.0

	set_collisions_enabled(true)
	


	set_state(State.CHASE)

func despawn_rat() -> void:
	if disappearing or current_state == State.DEFEAT:
		return

	rat_idle.stop()
	disappearing = true

	velocity = Vector2.ZERO

	var disappear_position := global_position

	# instantly hide rat
	sprite.modulate.a = 0.0

	set_collisions_enabled(false)

	set_state(State.REST)

	active = false

	# play closing hole AFTER despawn
	spawn_hole(disappear_position, "close")

func spawn_hole(pos : Vector2, anim : String) -> void:
	if hole_scene == null:
		return

	var hole = hole_scene.instantiate()

	get_parent().add_child(hole)

	hole.global_position = pos

	#hole.z_index = z_index - 1
	hole.z_index = 100
	

	var hole_sprite := hole.get_node_or_null("AnimatedSprite2D")

	if hole_sprite:
		hole_sprite.play(anim)

func set_collisions_enabled(enabled : bool) -> void:
	$CollisionShape2D.disabled = !enabled

	if hurtbox:
		hurtbox.monitoring = enabled
		hurtbox.monitorable = enabled

	if hitbox:
		hitbox.monitoring = enabled
		hitbox.monitorable = enabled

func take_damage(_damage: int, _knockback: Vector2 = Vector2.ZERO) -> void:
	if current_state == State.DEFEAT:
		return
	
	rat_idle.stop()
	rat_hit.play()
	set_state(State.DEFEAT)

	velocity = Vector2.ZERO

	set_collisions_enabled(false)

	sprite.modulate.a = 1.0

	sprite.play("defeat")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "defeat":
		queue_free()

func apply_world_bounds() -> void:
	global_position.x = clamp(global_position.x,
		WORLD_LEFT,
		WORLD_RIGHT
	)

	global_position.y = clamp(global_position.y,
		WORLD_TOP,
		WORLD_BOTTOM
	)
