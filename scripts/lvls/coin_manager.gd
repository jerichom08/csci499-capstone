extends Node

var banked_coins: int = 0	# permanent
var room_coins: int = 0		# temporary (since last room)

var collected_banked = {}
var collected_run = {}

signal coins_changed(total)

func get_total() -> int:
	return banked_coins + room_coins

func add_room_coin(amount: int = 1) -> void:
	room_coins += amount
	emit_signal("coins_changed", get_total())
	
func is_coin_collected(coin_id: String) -> bool:
	return collected_banked.has(coin_id) or collected_run.has(coin_id)

func mark_coin_collected(coin_id: String) -> void:
	collected_run[coin_id] = true

func reset_room_coins() -> void:
	room_coins = 0
	collected_run.clear()
	emit_signal("coins_changed", get_total())

func bank_room_coins() -> void:
	banked_coins += room_coins
	room_coins = 0
	
	for id in collected_run.keys():
		collected_banked[id] = true
	
	collected_run.clear()
	emit_signal("coins_changed", get_total())
