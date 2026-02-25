# res://test/test_player.gd
extends GutTest

class PlayerHarness:
	extends Node
	const SPEED := 300.0
	const JUMP_VELOCITY := -400.0

	var velocity := Vector2.ZERO
	var on_floor := true
	var gravity := Vector2(0, 980.0)
	var move_and_slide_called := false

	func _physics_process(delta: float) -> void:
		# player.gd logic (but using harness fields)
		if not on_floor:
			velocity += gravity * delta

		if Input.is_action_just_pressed("ui_accept") and on_floor:
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide_called = true


func after_each() -> void:
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	Input.action_release("ui_accept")


func test_gravity_applies_when_not_on_floor() -> void:
	var p := PlayerHarness.new()
	add_child_autofree(p)

	p.on_floor = false
	p.velocity = Vector2.ZERO
	p.gravity = Vector2(0, 1000)

	p._physics_process(0.1)

	assert_almost_eq(p.velocity.y, 100.0, 0.0001)


func test_jump_sets_velocity_y_when_on_floor_and_just_pressed() -> void:
	var p := PlayerHarness.new()
	add_child_autofree(p)

	p.on_floor = true
	p.velocity = Vector2.ZERO

	Input.action_press("ui_accept")
	p._physics_process(1.0 / 60.0)
	Input.action_release("ui_accept")

	assert_eq(p.velocity.y, p.JUMP_VELOCITY)


func test_horizontal_right_sets_velocity_x() -> void:
	var p := PlayerHarness.new()
	add_child_autofree(p)

	p.on_floor = true
	p.velocity = Vector2.ZERO

	Input.action_press("ui_right")
	p._physics_process(1.0 / 60.0)
	Input.action_release("ui_right")

	assert_eq(p.velocity.x, p.SPEED)


func test_no_input_moves_toward_zero() -> void:
	var p := PlayerHarness.new()
	add_child_autofree(p)

	p.velocity.x = 150.0
	p._physics_process(1.0 / 60.0)

	assert_eq(p.velocity.x, 0.0)


func test_move_and_slide_is_called_flag() -> void:
	var p := PlayerHarness.new()
	add_child_autofree(p)

	p.move_and_slide_called = false
	p._physics_process(1.0 / 60.0)

	assert_true(p.move_and_slide_called)
