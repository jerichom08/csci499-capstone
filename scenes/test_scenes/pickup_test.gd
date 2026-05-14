extends Node2D

@onready var items = $Items


func _on_reset_button_pressed() -> void:
	# Respawn items
	for item in items.get_children():
		if item.has_method("respawn"):
			item.respawn()

	# Clear player inventory
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.inventory.clear()
		player.selected_item_index = -1
		player.clear_held_item()
