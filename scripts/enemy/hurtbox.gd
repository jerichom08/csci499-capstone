class_name Hurtbox extends Area2D

func take_hit(damage: int) -> void:
	owner.take_damage(damage)
	print("Hurtbox takes damage")
