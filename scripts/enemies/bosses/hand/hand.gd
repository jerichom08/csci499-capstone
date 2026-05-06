extends EnemyBase

@export var hand_clone_scene: PackedScene
@export var clone_speed: float = 250.0
@export var clone_lifetime: float = 2.0
@export var gravity: float = 900.0
@export var heal_clone_count: int = 3
var WORLD_SCALE = 3.0

var is_healing := false

func _ready() -> void:
	super._ready()
	scale *= WORLD_SCALE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	update_state_machine()
	move_and_slide()

func chase() -> void:
	set_state(State.CHASE)

	var player : CharacterBody2D = get_player()
	print(player)
	if player == null:
		velocity.x = 0
		return

	var dir : int = sign(player.global_position.x - global_position.x)
	face_direction(dir)

	velocity.x = dir * stats.move_speed

	var distance : int = abs(player.global_position.x - global_position.x)

	if distance <= 250 and can_attack:
		set_state(State.ATTACK)

func attack() -> void:
	if not can_attack:
		return

	can_attack = false

	var player := get_player()
	if player != null:
		spawn_attack_clone(player.global_position)

	await get_tree().create_timer(1.5).timeout

	can_attack = true

func spawn_attack_clone(target_position: Vector2) -> void:
	if hand_clone_scene == null:
		return

	var clone = hand_clone_scene.instantiate()
	get_parent().add_child(clone)

	clone.global_position = global_position

	# smaller clone
	clone.scale = scale * 0.7

	# send clone toward player
	var direction := (target_position - global_position).normalized()

	clone.velocity = direction * clone_speed

	# auto despawn
	var tween := clone.create_tween()
	tween.tween_interval(clone_lifetime)
	tween.tween_property(clone.sprite, "modulate:a", 0.0, 0.25)
	tween.tween_callback(clone.queue_free)

func hit(damage: int) -> void:
	if is_dead or is_healing:
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
	is_healing = true

	set_state(State.HEAL)

	# spawn healing clones directly on top
	for i in range(heal_clone_count):
		var clone = hand_clone_scene.instantiate()
		get_parent().add_child(clone)

		clone.global_position = global_position
		clone.scale = scale * randf_range(0.8, 1.1)

		clone.sprite.modulate.a = 0.7

		var tween := clone.create_tween()
		tween.tween_interval(0.4)
		tween.tween_property(clone.sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(clone.queue_free)

	await get_tree().create_timer(0.5).timeout

	fade_out_and_free()

func take_damage(damage: int, knockback: Vector2 = Vector2.ZERO) -> void:
	hit(damage)
