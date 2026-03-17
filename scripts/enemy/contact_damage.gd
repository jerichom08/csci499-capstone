extends Area2D

@export var damage: int = 1
@export var knockback_strength: float = 180.0
@export var damage_cooldown: float = 0.5

var cooldown: float = 0.0

@onready var enemy: Node2D = get_parent()

func _physics_process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta


func _on_body_entered(body: Node2D) -> void:
	print("contact damage triggered")
	if cooldown > 0.0:
		return

	if not body.is_in_group("player"):
		return

	var dir := signf(body.global_position.x - enemy.global_position.x)
	var knockback := Vector2(dir * knockback_strength, -80.0)

	if body.has_method("take_damage"):
		body.take_damage(damage)
		cooldown = damage_cooldown
