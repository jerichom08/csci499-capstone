# res://test/test_character_body_2d_gd.gd
extends GutTest

class FakeSprite:
	extends Node
	var flip_h := false
	var animation := ""
	var played := []
	func play(name: String) -> void:
		animation = name
		played.append(name)

class CharacterHarness:
	extends Node

	const maxSpeed := 150.0
	const jumpVelocity := -200.0
	const gravity := 400.0
	const acceleration := 600.0
	const deceleration := 800.0
	const airAcceleration := 600.0

	var velocity := Vector2.ZERO
	var is_attacking := false
	var on_floor := true

	var sprite := FakeSprite.new()
	var attack_spawn := Node2D.new()

	var spawn_attack_called := false
	var move_and_slide_called := false

	func _init() -> void:
		attack_spawn.position = Vector2(10, 0)
		add_child(sprite)
		add_child(attack_spawn)

	func spawn_attack() -> void:
		spawn_attack_called = true

	func _physics_process(delta: float) -> void:
		# character_body_2d.gd logic (but using harness fields)
		if not on_floor:
			velocity.y += gravity * delta

		if Input.is_action_just_pressed("jump") and on_floor and not is_attacking:
			velocity.y = jumpVelocity

		var direction := Input.get_axis("move_left", "move_right")
		if not is_attacking:
			var accel := acceleration if on_floor else airAcceleration
			velocity.x = move_toward(velocity.x, direction * maxSpeed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)

		if Input.is_action_just_pressed("attack") and not is_attacking and on_floor:
			spawn_attack()
			is_attacking = true
			sprite.play("attack")

		if is_attacking:
			pass
		elif direction == 0:
			sprite.play("idle")
		else:
			sprite.play("run")

		if direction != 0 and not is_attacking:
			sprite.flip_h = direction < 0
			attack_spawn.position.x = abs(attack_spawn.position.x) * (-1 if sprite.flip_h else 1)

		move_and_slide_called = true

	func on_animation_finished() -> void:
		if sprite.animation == "attack":
			is_attacking = false


func _ensure_action(name: String) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)


func before_each() -> void:
	_ensure_action("move_left")
	_ensure_action("move_right")
	_ensure_action("jump")
	_ensure_action("attack")


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")


func test_gravity_applies_in_air() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = false
	c.velocity = Vector2.ZERO

	c._physics_process(0.5)

	assert_almost_eq(c.velocity.y, 200.0, 0.0001)


func test_jump_sets_velocity_y_only_when_on_floor_and_not_attacking() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = true
	c.is_attacking = false
	c.velocity = Vector2.ZERO

	Input.action_press("jump")
	c._physics_process(1.0 / 60.0)
	Input.action_release("jump")
	assert_eq(c.velocity.y, c.jumpVelocity)

	# blocked while attacking
	c.velocity.y = 0
	c.is_attacking = true
	Input.action_press("jump")
	c._physics_process(1.0 / 60.0)
	Input.action_release("jump")
	assert_eq(c.velocity.y, 0)


func test_attack_on_floor_sets_attacking_plays_attack_and_calls_spawn() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = true
	c.is_attacking = false
	c.spawn_attack_called = false

	Input.action_press("attack")
	c._physics_process(1.0 / 60.0)
	Input.action_release("attack")

	assert_true(c.spawn_attack_called)
	assert_true(c.is_attacking)
	assert_eq(c.sprite.animation, "attack")


func test_attack_does_not_trigger_in_air() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = false
	c.is_attacking = false

	Input.action_press("attack")
	c._physics_process(1.0 / 60.0)
	Input.action_release("attack")

	assert_false(c.spawn_attack_called)
	assert_false(c.is_attacking)


func test_run_idle_animation_when_not_attacking() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = true
	c.is_attacking = false

	c._physics_process(1.0 / 60.0)
	assert_eq(c.sprite.animation, "idle")

	Input.action_press("move_right")
	c._physics_process(1.0 / 60.0)
	Input.action_release("move_right")
	assert_eq(c.sprite.animation, "run")


func test_flip_and_attackspawn_position_when_moving_left() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = true
	c.is_attacking = false
	c.attack_spawn.position.x = 10

	Input.action_press("move_left")
	c._physics_process(1.0 / 60.0)
	Input.action_release("move_left")

	assert_true(c.sprite.flip_h)
	assert_eq(c.attack_spawn.position.x, -10.0)


func test_decelerates_toward_zero_while_attacking() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.on_floor = true
	c.is_attacking = true
	c.velocity.x = 100.0

	c._physics_process(0.1) # decel*dt = 800*0.1 = 80 => 100 -> 20
	assert_almost_eq(c.velocity.x, 20.0, 0.0001)


func test_attack_finished_resets_is_attacking() -> void:
	var c := CharacterHarness.new()
	add_child_autofree(c)

	c.is_attacking = true
	c.sprite.animation = "attack"

	c.on_animation_finished()
	assert_false(c.is_attacking)
