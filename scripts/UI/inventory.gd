extends CanvasLayer

@onready var slots: Array[TextureRect] = [
	$Panel/HBoxContainer/Slot1,
	$Panel/HBoxContainer/Slot2,
	$Panel/HBoxContainer/Slot3,
	$Panel/HBoxContainer/Slot4,
	$Panel/HBoxContainer/Slot5
]

func _ready() -> void:
	visible = false
	clear_slots()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = !visible

		if visible:
			update_inventory()

func update_inventory() -> void:
	clear_slots()

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("No player found")
		return

	print("Inventory size: ", player.inventory.size())

	for i in range(min(player.inventory.size(), slots.size())):
		slots[i].texture = player.inventory[i]["texture"]

		slots[i].custom_minimum_size = Vector2(20, 20)

		slots[i].expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slots[i].stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func clear_slots() -> void:
	for slot in slots:
		slot.texture = null
