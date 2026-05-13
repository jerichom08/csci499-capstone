extends Node

var banked_coins: int = 0	# permanent
var room_coins: int = 0		# temporary (since last room)

signal coins_changed(total)

func get_total() -> int:
	return banked_coins + room_coins

func add_room_coin(amount: int = 1) -> void:
	room_coins += amount
	emit_signal("coins_changed", get_total())

func bank_room_coins() -> void:
	banked_coins += room_coins
	room_coins = 0
	emit_signal("coins_changed", get_total())

func reset_room_coins() -> void:
	room_coins = 0
	emit_signal("coins_changed", get_total())
