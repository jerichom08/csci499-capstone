extends Hitbox

var force: float = -100000.0

func _ready() -> void:
	super._ready()

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)

func _on_area_entered(area: Area2D) -> void:
	super._on_area_entered(area)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body is CharacterBody2D:
		body.velocity.y = force
