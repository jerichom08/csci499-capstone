extends Area2D

signal item_picked_up(item_name: String)

@export var item_name: String = "key"

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("add_item"):
		var item_sprite: Sprite2D = null

		for child in get_children():
			if child is Sprite2D:
				item_sprite = child
				break

		if item_sprite == null:
			print("ERROR: No Sprite2D child found.")
			return

		if item_sprite.texture == null:
			print("ERROR: Sprite2D has no texture.")
			return

		print("Picking up:", item_name)

		body.add_item(item_name, item_sprite.texture)

		item_picked_up.emit(item_name)

		queue_free()
