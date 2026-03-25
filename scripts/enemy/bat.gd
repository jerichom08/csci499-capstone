extends CharacterBody2D

@export var stats: Stats
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var start_x: float
var just_turned := false

func _ready() -> void:
	if stats:
		stats = stats.duplicate()
	start_x = global_position.x

func _physics_process(_delta: float) -> void:
	just_turned = false

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
	if just_turned:
		return

	stats.direction *= -1
	sprite.flip_h = stats.direction < 0
	$VisionRay.scale.x *= -1
	just_turned = true

func take_damage(amount: int = 1) -> void:
	print("bat takes damage: ", amount)
