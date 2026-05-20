extends Node

signal ingredients_changed

var collected_ingredients: Array[Texture2D] = []

func add_ingredient(texture: Texture2D) -> void:
	collected_ingredients.append(texture)
	ingredients_changed.emit()
