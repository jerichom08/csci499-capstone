class_name Hitbox extends Area2D

@export var damage: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	print("detected an Area: ", area)
	print("name: ", area.name)
	print("scene path: ", area.get_path())
	print("script: ", area.get_script())

	if area.owner == owner:
		print("ignoring my own collision bodies")
		return

	if area is Hurtbox:
		print("detected a Hurtbox")
		area.take_hit(damage)
	else:
		print("this area is NOT a Hurtbox")
