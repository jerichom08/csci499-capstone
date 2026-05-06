extends HBoxContainer

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

func _ready():
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("Player not found in group")
		return
	
	player.health_changed.connect(update_hearts)
	update_hearts(player.health, player.max_health)
	
func update_hearts(current_hp: int, max_hp: int):
	for i in range(3):
		var heart_hp = current_hp - (i * 2)
			
		if heart_hp >= 2:
			hearts[i].texture = full_heart
		elif heart_hp == 1:
			hearts[i].texture = half_heart
		else:
			hearts[i].texture = empty_heart
