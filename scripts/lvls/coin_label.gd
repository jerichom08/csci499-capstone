extends Node

signal coins_changed(total)

var total: int = 0

func get_total() -> int:
	return total
