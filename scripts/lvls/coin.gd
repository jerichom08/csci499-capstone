extends Label


func _ready() -> void:
	update_text(CoinManager.get_total())

	if not CoinManager.coins_changed.is_connected(_on_coins_changed):
		CoinManager.coins_changed.connect(_on_coins_changed)


func _on_coins_changed(total: int) -> void:
	update_text(total)


func update_text(total: int) -> void:
	if total < 10:
		text = "0" + str(total)
	else:
		text = str(total)
