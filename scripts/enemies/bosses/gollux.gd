extends EnemyBase

@export var speed: float = 40.0
@export var attack_cooldown: float = 5.0
@export var attack_anim: StringName = &"attack_b"
@export var attack_lock_time: float = 0.8

# Vision behavior
@export var chase_when_seen: bool = true
@export var lose_target_time: float = 3.0

# Ledge behavior (WallRay is used as the ledge ray)
@export var stop_at_ledge: bool = true
@export var turn_around_at_ledge: bool = true

@onready var vision_ray: RayCast2D = $VisionRay
@onready var wall_ray: RayCast2D = $WallRay # configured as ledge ray

var player: Node2D
var timer := 0.0
var attack_lock := 0.0
var last_seen := 0.0

func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group("player")
	_enter_state(State.IDLE)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	timer += delta
	attack_lock = maxf(attack_lock - delta, 0.0)

	if player == null:
		velocity.x = 0.0
		super._physics_process(delta)
		return

	# Face player (affects ray direction + sprite flip)
	set_facing_from_x(player.global_position.x)
	_update_vision_ray()
	_update_wall_ray()

	var sees_player := _ray_sees_player()
	if sees_player:
		last_seen = lose_target_time
	else:
		last_seen = maxf(last_seen - delta, 0.0)

	# Ledge check: if no ground ahead, we are at a ledge
	var at_ledge := stop_at_ledge and _ledge_has_no_ground()

	# If ledge detected and we're not attacking, optionally turn around
	if at_ledge and turn_around_at_ledge and attack_lock <= 0.0 and state != State.ATTACK:
		_turn_around()
		_update_vision_ray()
		_update_wall_ray()
		at_ledge = _ledge_has_no_ground() # re-check after turning

	# Attack trigger
	var can_try_attack := (timer >= attack_cooldown) and (attack_lock <= 0.0)
	if can_try_attack and (sees_player or last_seen > 0.0):
		timer = 0.0
		attack_lock = attack_lock_time
		_enter_state(State.ATTACK)
	else:
		# Movement decision: only run if we have LOS memory AND not at ledge
		if chase_when_seen and (sees_player or last_seen > 0.0) and attack_lock <= 0.0 and not at_ledge:
			_enter_state(State.RUN)
		elif attack_lock <= 0.0:
			_enter_state(State.IDLE)

	match state:
		State.IDLE:
			velocity.x = 0.0
			_try_play("idle")

		State.RUN:
			# If ledge appears mid-run, stop (turn-around handled above)
			if at_ledge:
				velocity.x = 0.0
				_enter_state(State.IDLE)
				_try_play("idle")
			else:
				velocity.x = float(facing_dir) * speed
				_try_play("run")

		State.ATTACK:
			velocity.x = 0.0
			if attack_lock > 0.0:
				_try_play(String(attack_anim))
			else:
				_enter_state(State.IDLE)

		State.HURT:
			_try_play("hurt")

		State.DEFEAT:
			pass

	super._physics_process(delta)

# --- Ray helpers ---

func _update_vision_ray() -> void:
	var tp := vision_ray.target_position
	tp.x = absf(tp.x) * float(facing_dir)
	vision_ray.target_position = tp
	vision_ray.force_raycast_update()

func _update_wall_ray() -> void:
	# WallRay is a ledge ray (down+forward). Mirror X only.
	var tp := wall_ray.target_position
	tp.x = absf(tp.x) * float(facing_dir)
	wall_ray.target_position = tp
	wall_ray.force_raycast_update()

func _ray_sees_player() -> bool:
	if not vision_ray.is_colliding():
		return false
	var col := vision_ray.get_collider()
	return col != null and col.is_in_group("player")

func _ledge_has_no_ground() -> bool:
	# For ledge rays: NOT colliding means no ground ahead.
	return not wall_ray.is_colliding()

func _turn_around() -> void:
	facing_dir *= -1
	sprite.flip_h = facing_dir < 0
