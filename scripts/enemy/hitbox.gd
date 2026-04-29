class_name Hitbox extends Area2D

@export var damage: int = 1
@export var apply_knockback: bool = false
@export var knockback_force: float = 800.0
@export var knockback_upward: float = -300.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.owner == owner:
		return

	if area is Hurtbox:
		var knockback := Vector2.ZERO

		if apply_knockback:
			var dir : int = sign(area.global_position.x - global_position.x)
			if dir == 0:
				dir = 1
			knockback = Vector2(dir * knockback_force, knockback_upward)

		area.take_hit(damage, knockback)
