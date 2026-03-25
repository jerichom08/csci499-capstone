extends CharacterBody2D

@export var stats: Stats
@export var death_gravity: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox

var start_x: float
var just_turned := false
var is_dead := false
var is_hurt := false

func _ready() -> void:
	if stats:
		stats = stats.duplicate()
	start_x = global_position.x
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	just_turned = false

	if is_dead:
		velocity.x = 0
		velocity.y += death_gravity * delta
		move_and_slide()
		return

	if not stats:
		return

	var distance := global_position.x - start_x

	if stats.direction > 0 and distance > stats.range_x:
		turn_around()
	elif stats.direction < 0 and distance < -stats.range_x:
		turn_around()

	velocity.x = stats.direction * stats.speed
	velocity.y = 0
	move_and_slide()

func turn_around() -> void:
	if just_turned or is_dead:
		return

	stats.direction *= -1
	sprite.flip_h = stats.direction < 0
	$VisionRay.scale.x *= -1
	just_turned = true

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	if not stats:
		return

	stats.hp -= amount
	print("bat takes damage: ", amount)

	if stats.hp <= 0:
		die()
	else:
		is_hurt = true
		sprite.play("hurt")

func die() -> void:
	print("is being called")
	if is_dead:
		return

	is_dead = true
	is_hurt = false
	velocity = Vector2.ZERO

	if hurtbox:
		hurtbox.monitorable = false
		hurtbox.monitoring = false

	sprite.play("death")

func _on_animation_finished() -> void:
	print("finished animation: ", sprite.animation)

	if is_dead and sprite.animation == "death":
		queue_free()
	elif not is_dead and sprite.animation == "hurt":
		is_hurt = false
		sprite.play("idle")
