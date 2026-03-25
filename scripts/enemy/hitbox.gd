class_name Hitbox extends Area2D

@export var damage: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		area.take_hit(damage)
