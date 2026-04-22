extends CharacterBody2D

@export var frog_spit_attack: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction = 1

func _ready() -> void:
	sprite.play("light_attack")
	
	var spit = $FrogSpit
	var spit_sprite = spit.get_node("AnimatedSprite2D")
	
	spit.global_position = $SpitSpawn.global_position
	spit.visible = true
	
	if facing_direction < 0:
		spit.scale.x = -abs(spit.scale.x)
	else:
		spit.scale.x = abs(spit.scale.x)
	
	spit_sprite.play("spit")
