extends Node2D

@onready var p: TileMapLayer = $"path up"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p.visible = false
	p.collision_enabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	SceneTransition.change_scene_to("res://scenes/levels/level_4/scene_1.tscn")
	
#joey needs to connect this signal
#func _on_boss_defeated() -> void:
	#p.visible = true
	#p.collision_enabled = true


func _on_gollux_boss_defeated() -> void:
	p.visible = true
	p.collision_enabled = true
