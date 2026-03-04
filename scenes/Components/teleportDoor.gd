extends Area2D

@export var target_path: NodePath
@export var spawn_path: NodePath
@export var send_to_spawn: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	#teleports player
	if not body.is_in_group("Player"):
		return
		
	var destination_node: Node2D = null
	
	if send_to_spawn:
		if spawn_path == NodePath():
			push_warning("TeleportDoor: Spawn_path not set")
			return
		destination_node = get_node(spawn_path) as Node2D
	else: 
		if target_path == NodePath():
			push_warning("TeleportDoor: Spawn_path not set")
			return
		destination_node = get_node(target_path) as Node2D
	if destination_node == null:
		push_warning("TeleportDoor: destination node not found or not Node2D ")
		return
	body.global_position = destination_node.global_position
