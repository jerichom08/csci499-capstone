extends Area2D

@export var item_name: String = "key"

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("add_item"):
		var item_sprite := find_child("Sprite2D", true, false) as Sprite2D

		print("Found sprite: ", item_sprite)

		if item_sprite == null:
			print("ERROR: No Sprite2D child found on this item.")
			return

		print("Sprite texture: ", item_sprite.texture)

		if item_sprite.texture == null:
			print("ERROR: Sprite2D has no texture.")
			return

		body.add_item(item_name, item_sprite.texture)
		queue_free()
