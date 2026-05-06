extends Area2D

var player = null

func _ready() -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area  == null or area.owner == null:
		return
	if area.owner.is_in_group("player"):
		player = area.owner
	#print(player)
	
func _on_area_exited(area: Area2D) -> void:
	if area == null or area.owner == null:
		return
	if area.owner.is_in_group("player"):
		player = null

func can_see_player() -> bool:
	return player != null
