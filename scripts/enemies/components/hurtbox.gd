class_name Hurtbox extends Area2D

#func _ready() -> void:
	#set_collision_layer_value(3, true)
	#set_collision_mask_value(2, true)

func take_hit(damage: int, knockback: Vector2) -> void:
	owner.take_damage(damage, knockback)
