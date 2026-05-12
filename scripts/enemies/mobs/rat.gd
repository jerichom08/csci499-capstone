extends EnemyBase

const WORLD_LEFT   : float = 0.0
const WORLD_RIGHT  : float = 5000.0
const WORLD_TOP    : float = 120.0   
const WORLD_BOTTOM : float = 720.0

@export var chase_speed : float = 350.0
@export var burst_duration : float = 0.4
@export var chase_duration : float = 1.5
@export var underground_wait : float = 1.0
@export var underground_distance : float = 80.0
@export var player_offset : float = 20.0

var emerging := false
var disappearing := false
var base_y : float

func _ready() -> void:
	super._ready()

	scale *= 3

	base_y = global_position.y

	# disable collisions underground
	set_collisions_enabled(false)

	# start underground
	global_position.y += underground_distance
	sprite.modulate.a = 1.0

	emerge()

func _physics_process(delta: float) -> void:
	if emerging or disappearing:
		move_and_slide()
		return

	var player := get_player()

	if player == null:
		velocity.x = 0
		move_and_slide()
		return

	var target_x : float

	if global_position.x < player.global_position.x:
		target_x = player.global_position.x - player_offset
	else:
		target_x = player.global_position.x + player_offset

	var dir : int = sign(target_x - global_position.x)

	face_direction(dir)

	velocity.x = dir * chase_speed

	if abs(global_position.x - target_x) <= 10:
		velocity.x = 0

	move_and_slide()

func emerge() -> void:
	emerging = true
	disappearing = false

	# enable collisions when emerging
	set_collisions_enabled(true)

	sprite.play("idle")

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position:y",
		base_y,
		burst_duration
	)

	await tween.finished

	emerging = false

	sprite.play("chase")

	await get_tree().create_timer(chase_duration).timeout

	go_underground()

func go_underground() -> void:
	disappearing = true

	velocity = Vector2.ZERO

	sprite.play("idle")

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"global_position:y",
		base_y + underground_distance,
		burst_duration
	)

	tween.tween_property(
		sprite,
		"modulate:a",
		0.0,
		burst_duration
	)

	await tween.finished

	# disable collisions underground
	set_collisions_enabled(false)

	disappearing = false

	await get_tree().create_timer(underground_wait).timeout

	sprite.modulate.a = 1.0

	emerge()

func set_collisions_enabled(enabled : bool) -> void:
	$CollisionShape2D.disabled = !enabled

	if hurtbox:
		hurtbox.monitoring = enabled
		hurtbox.monitorable = enabled

	if hitbox:
		hitbox.monitoring = enabled
		hitbox.monitorable = enabled
