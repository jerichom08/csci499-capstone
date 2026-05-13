extends Node

signal coins_changed

var total_coins: int = 0


func add_coin(amount: int = 1) -> void:
	total_coins += amount
	coins_changed.emit(total_coins)


func get_total() -> int:
	return total_coins
