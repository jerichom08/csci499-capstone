extends CharacterBody2D

@export var speed: float = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D
var timer := 0.0
var attack_lock := 0.0   # prevents run animation while attacking

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# countdown attack lock
	attack_lock = maxf(attack_lock - delta, 0.0)

	# CHASE PLAYER
	var dir := signf(player.global_position.x - global_position.x)
	velocity.x = dir * speed

	# flip toward player
	if dir != 0:
		sprite.flip_h = dir < 0

	# ATTACK EVERY 5 SECONDS
	timer += delta
	if timer >= 5.0:
		timer = 0.0
		attack_lock = 0.8   # how long floor_slam lasts (adjust)
		sprite.play("floor_slam")

	# only play run if not attacking
	if attack_lock <= 0.0:
		sprite.play("run")

	move_and_slide()
