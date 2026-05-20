extends Node

signal ingredients_changed

var collected_ingredients: Array[Dictionary] = []

func add_ingredient(texture: Texture2D, hud_scale: Vector2 = Vector2.ONE) -> void:
	collected_ingredients.append({
		"texture": texture,
		"scale": hud_scale
	})
	ingredients_changed.emit()
