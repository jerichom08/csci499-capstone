class_name Hurtbox extends Area2D

func take_hit(damage: int, knockback: Vector2) -> void:
	owner.take_damage(damage, knockback)
