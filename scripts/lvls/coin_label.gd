extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "0" + str(CoinManager.get_total())
	CoinManager.coins_changed.connect(_on_coins_changed)


func _on_coins_changed(total):
	if (total < 10):
		text = "0" + str(total)
	else:
		text = str(total)
