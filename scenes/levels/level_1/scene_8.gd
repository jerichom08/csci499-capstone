extends Node2D

@onready var p: TileMapLayer = $p


func _on_area_2d_body_entered(body: Node2D) -> void:
	SceneTransition.change_scene_to("res://scenes/levels/level_2/scene_1.tscn")
	



func _on_ready() -> void:
	p.visible = false
	p.collision_enabled = false


func _on_frog_boss_defeated() -> void:
	p.visible = true
	p.collision_enabled = true
