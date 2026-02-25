# File: scripts/enemy/EnemyBase.gd
extends CharacterBody2D
class_name EnemyBase

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }

@export_category("Core")
@export var max_health: int = 3
@export var move_speed: float = 50.0
@export var gravity: float = 1200.0

@export_category("AI")
@export var detection_range: float = 160.0
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.25
@export var lose_target_after: float = 1.0

@export_category("Patrol")
@export var patrol_enabled: bool = true
@export var patrol_left_x: float = -64.0   # local-space relative bounds
@export var patrol_right_x: float = 64.0   # local-space relative bounds
@export var patrol_pause_time: float = 0.2

@export_category("Combat")
@export var contact_damage: int = 1
@export var knockback_strength: float = 220.0
@export var hurt_lock_time: float = 0.25

@export_category("Nodes")
@export var sprite_path: NodePath
@export var anim_path: NodePath

var health: int
var state: State = State.PATROL
var facing: int = 1  # 1 right, -1 left

var target: Node2D = null
var _home_x: float
var _patrol_dir: int = 1

var _attack_timer: float = 0.0
var _lost_timer: float = 0.0
var _patrol_pause: float = 0.0
var _hurt_timer: float = 0.0

@onready var sprite := (get_node_or_null(sprite_path) as Node)
@onready var anim := (get_node_or_null(anim_path) as AnimationPlayer)

func _ready() -> void:
	health = max_health
	_home_x = global_position.x
	_find_player()
	_enter_state(State.PATROL if patrol_enabled else State.IDLE)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	_attack_timer = maxf(_attack_timer - delta, 0.0)

	if state == State.DEAD:
		return

	_update_target(delta)

	match state:
		State.IDLE:
			_do_idle(delta)
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack(delta)
		State.HURT:
			_do_hurt(delta)

	move_and_slide()
	_update_visuals()

# --------------------------
# Public API (for children)
# --------------------------

func take_damage(amount: int, source_global_pos: Vector2 = global_position) -> void:
	if state == State.DEAD:
		return

	health -= amount
	if health <= 0:
		die()
		return

	# Knockback away from source
	var dir := signf(global_position.x - source_global_pos.x)
	if dir == 0.0:
		dir = float(-facing)
	velocity.x = dir * knockback_strength

	_enter_state(State.HURT)

func die() -> void:
	_enter_state(State.DEAD)
	velocity = Vector2.ZERO
	_play_anim("dead")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

# Child classes can override these to customize behavior without rewriting base logic.
func wants_to_attack() -> bool:
	return target != null and _dist_to_target() <= attack_range and _attack_timer <= 0.0

func perform_attack() -> void:
	# Override in child: spawn hitbox, shoot, etc.
	# Base just plays animation and starts cooldown.
	_play_anim("attack")
	_attack_timer = attack_cooldown

func on_target_acquired() -> void:
	pass

func on_target_lost() -> void:
	pass

# --------------------------
# State machine
# --------------------------

func _enter_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state

	match state:
		State.IDLE:
			_play_anim("idle")
		State.PATROL:
			_play_anim("run")
		State.CHASE:
			_play_anim("run")
		State.ATTACK:
			# Let _do_attack trigger the actual attack.
			pass
		State.HURT:
			_hurt_timer = hurt_lock_time
			_play_anim("hurt")
		State.DEAD:
			# die() handles visuals/collision
			pass

func _do_idle(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, move_speed * 6.0)

	if wants_to_attack():
		_enter_state(State.ATTACK)
	elif target != null:
		_enter_state(State.CHASE)
	elif patrol_enabled:
		_enter_state(State.PATROL)

func _do_patrol(delta: float) -> void:
	if _patrol_pause > 0.0:
		_patrol_pause -= delta
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 6.0)
		return

	var left_bound := _home_x + patrol_left_x
	var right_bound := _home_x + patrol_right_x

	if global_position.x <= left_bound:
		_patrol_dir = 1
		_patrol_pause = patrol_pause_time
	elif global_position.x >= right_bound:
		_patrol_dir = -1
		_patrol_pause = patrol_pause_time

	velocity.x = _patrol_dir * move_speed

	if wants_to_attack():
		_enter_state(State.ATTACK)
	elif target != null:
		_enter_state(State.CHASE)

func _do_chase(_delta: float) -> void:
	if target == null:
		_enter_state(State.PATROL if patrol_enabled else State.IDLE)
		return

	var dir := signf(target.global_position.x - global_position.x)
	velocity.x = dir * move_speed

	if wants_to_attack():
		_enter_state(State.ATTACK)

func _do_attack(_delta: float) -> void:
	if target == null:
		_enter_state(State.PATROL if patrol_enabled else State.IDLE)
		return

	# Stop to attack (common for melee); children can override perform_attack() for ranged.
	velocity.x = move_toward(velocity.x, 0.0, move_speed * 10.0)
	perform_attack()

	# After performing attack, transition based on whether target still valid.
	if target != null:
		_enter_state(State.CHASE if _dist_to_target() > attack_range else State.IDLE)
	else:
		_enter_state(State.PATROL if patrol_enabled else State.IDLE)

func _do_hurt(delta: float) -> void:
	_hurt_timer -= delta
	if _hurt_timer <= 0.0:
		_enter_state(State.CHASE if target != null else (State.PATROL if patrol_enabled else State.IDLE))

# --------------------------
# Targeting / sensing
# --------------------------

func _find_player() -> void:
	# Assumes the player is in group "player"
	target = get_tree().get_first_node_in_group("player") as Node2D

func _update_target(delta: float) -> void:
	if target == null or !is_instance_valid(target):
		target = null
		_lost_timer = 0.0
		return

	var d := _dist_to_target()

	if d <= detection_range:
		if _lost_timer > 0.0:
			_lost_timer = 0.0
		# acquired
		if state in [State.IDLE, State.PATROL] and !wants_to_attack():
			on_target_acquired()
	else:
		# out of range: start "lose target" timer
		_lost_timer += delta
		if _lost_timer >= lose_target_after:
			target = null
			_lost_timer = 0.0
			on_target_lost()

func _dist_to_target() -> float:
	if target == null:
		return INF
	return global_position.distance_to(target.global_position)

# --------------------------
# Movement / visuals
# --------------------------

func _apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		# prevent accumulation
		velocity.y = minf(velocity.y, 0.0)

func _update_visuals() -> void:
	# Determine facing from movement/target
	if target != null:
		var dir := signf(target.global_position.x - global_position.x)
		if dir != 0.0:
			facing = int(dir)
	elif absf(velocity.x) > 0.1:
		facing = 1 if velocity.x > 0.0 else -1

	# Flip Sprite2D / AnimatedSprite2D if provided
	if sprite == null:
		return

	# Supports Sprite2D / AnimatedSprite2D
	if sprite.has_method("set_flip_h"):
		sprite.call("set_flip_h", facing < 0)
	elif "flip_h" in sprite:
		sprite.flip_h = (facing < 0)

func _play_anim(name: String) -> void:
	# If you use AnimatedSprite2D instead of AnimationPlayer, override this in child
	if anim == null:
		return
	if anim.has_animation(name):
		anim.play(name)
