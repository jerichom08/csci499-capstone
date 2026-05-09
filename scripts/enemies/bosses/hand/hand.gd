extends EnemyBase

@export var hand_clone_scene: PackedScene

@export var clone_speed: float = 700.0
@export var clone_lifetime: float = 0.5

@export var clone_count: int = 10
@export var clone_spacing: float = 40.0

@export var attack_range: float = 400.0
@export var attack_cooldown : float = 3.0

@export var gravity: float = 900.0

const WORLD_SCALE := 3.0

var attack_executed := false

func _ready() -> void:
	super._ready()

	scale *= WORLD_SCALE

	set_state(State.CHASE)

func _physics_process(delta: float) -> void:
	print(state_animations[current_state])

	if not is_on_floor():
		velocity.y += gravity * delta

	update_state_machine()

	move_and_slide()

func play_animation() -> void:
	match current_state:
		State.HIT:
			if sprite.animation != "hit":
				sprite.play("hit")

		_:
			if sprite.animation != "idle":
				sprite.play("idle")

func chase() -> void:
	var player := get_player()

	if player == null:
		velocity.x = 0
		return

	var dir : int = sign(player.global_position.x - global_position.x)

	face_direction(dir)

	velocity.x = dir * stats.move_speed

	var dx : float = abs(player.global_position.x - global_position.x)

	if dx <= attack_range and can_attack:
		set_state(State.ATTACK)

func attack() -> void:
	velocity.x = 0

	if attack_executed or !can_attack:
		return

	attack_executed = true
	can_attack = false

	var player := get_player()

	if player != null:
		spawn_clone_barrage(player)

	attack_executed = false

	# immediately resume chase
	set_state(State.CHASE)

	# cooldown before next attack
	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true

func spawn_clone_barrage(player : Node2D) -> void:
	var direction : int = sign(player.global_position.x - global_position.x)

	if direction == 0:
		direction = 1

	var offset := clone_spacing

	for i in range(clone_count):
		spawn_attack_clone(direction, offset)

		offset += clone_spacing

func spawn_attack_clone(direction : int, offset : float) -> void:
	if hand_clone_scene == null:
		return

	var clone = hand_clone_scene.instantiate()

	get_parent().add_child(clone)

	# progressively farther outward
	clone.global_position = global_position + Vector2(direction * offset, 0)

	clone.scale = scale * 0.8

	var clone_sprite : Sprite2D = clone.get_node_or_null("Sprite2D")

	if clone_sprite:
		clone_sprite.flip_h = direction < 0

	# movement
	if clone.has_method("set"):
		clone.set("velocity", Vector2(direction * clone_speed, 0))

	# despawn clone
	var tween := clone.create_tween()

	tween.tween_interval(clone_lifetime)

	if clone_sprite:
		tween.tween_property(
			clone_sprite,
			"modulate:a",
			0.0,
			0.1
		)

	tween.tween_callback(clone.queue_free)

func hit(damage: int) -> void:
	if is_dead:
		return

	health -= damage

	if health <= 0:
		defeat()
		return

	set_state(State.HIT)

func defeat() -> void:
	if is_dead:
		return

	is_dead = true

	velocity = Vector2.ZERO

	set_state(State.DEFEAT)

	sprite.modulate.a = 0.0

	set_collisions_enabled(false)

	queue_free()

func take_damage(damage: int, knockback: Vector2 = Vector2.ZERO) -> void:
	hit(damage)

func _on_animation_finished() -> void:
	match current_state:
		State.HIT:
			set_state(State.CHASE)

func set_collisions_enabled(enabled : bool) -> void:
	# main body collision
	$CollisionShape2D.disabled = !enabled

	# hurtbox
	if hurtbox:
		hurtbox.monitoring = enabled
		hurtbox.monitorable = enabled

	# hitbox
	if hitbox:
		hitbox.monitoring = enabled
		hitbox.monitorable = enabled
