extends Node

var max_health: int = 6
var health: int = 6

signal health_changed(current, max)

func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)

func heal(amount: int) -> void:
	health += amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)

func reset_health():
	health = max_health
	emit_signal("health_changed", health, max_health)
