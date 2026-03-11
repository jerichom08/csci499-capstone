# EnemyBase.gd
# Minimal base class for mobs/bosses to inherit from.
# Assumes a scene structure like:
# Enemy (CharacterBody2D)
# ├─ AnimatedSprite2D
# └─ CollisionShape2D

extends CharacterBody2D
class_name EnemyBase

enum State { IDLE, RUN, HURT, ATTACK, DEFEAT}

# --- Core stats ---
@export var max_health: int = 3
@export var move_speed: float = 50.0
@export var gravity: float = 900.0

# Optional: child enemies can set these per-mob
@export var can_run: bool = true
@export var can_attack: bool = true

# --- Runtime state ---
var health: int
var state: State = State.IDLE
var facing_dir: int = 1 # 1 = right, -1 = left
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	_enter_state(State.IDLE)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_apply_gravity(delta)
	_state_tick(delta)
	move_and_slide()

# -------------------------
# Public API (common calls)
# -------------------------
func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return

	health = max(health - amount, 0)

	if knockback != Vector2.ZERO:
		velocity += knockback

	if health <= 0:
		die()
	else:
		_enter_state(State.HURT)
		on_hurt() # override hook

func heal(amount: int) -> void:
	if is_dead:
		return
	health = min(health + amount, max_health)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	_enter_state(State.DEFEAT)
	on_defeat() # override hook

func set_facing_from_x(target_x: float) -> void:
	var dir := signf(target_x - global_position.x)
	if dir != 0:
		facing_dir = int(dir)
		sprite.flip_h = facing_dir < 0

# -------------------------
# State machine (minimal)
# -------------------------
func _enter_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	_play_state_anim(new_state)
	on_state_enter(new_state) # override hook

func _state_tick(delta: float) -> void:
	match state:
		State.IDLE:
			on_idle(delta)   # override hook
		State.RUN:
			on_run(delta)    # override hook
		State.HURT:
			on_hurt_tick(delta) # override hook (e.g., timed stun)
		State.ATTACK:
			on_attack(delta) # override hook
		State.DEFEAT:
			pass

func _play_state_anim(s: State) -> void:
	# Child classes decide which animations exist; this is just a safe default.
	match s:
		State.IDLE:
			_try_play("idle")
		State.RUN:
			_try_play("run")
		State.HURT:
			_try_play("hurt")
		State.ATTACK:
			_try_play("attack")
		State.DEFEAT:
			_try_play("defeat")

func _try_play(anim: String) -> void:
	if sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# -------------------------
# Override hooks (children)
# -------------------------
func on_state_enter(_new_state: State) -> void:
	pass

func on_idle(_delta: float) -> void:
	# Example default: if can_run, child might decide to patrol/chase then call _enter_state(RUN)
	pass

func on_run(_delta: float) -> void:
	pass

func on_attack(_delta: float) -> void:
	pass

func on_hurt() -> void:
	# Called once when damage taken and not dead
	pass

func on_hurt_tick(_delta: float) -> void:
	# Child can implement hurt stun timing then return to idle/run.
	pass

func on_defeat() -> void:
	# Child can disable collisions, drop loot, queue_free after animation, etc.
	pass
