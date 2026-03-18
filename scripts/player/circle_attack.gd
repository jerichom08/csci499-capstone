extends CharacterBody2D


var speed = 250
var direction = 1
var player = null

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("attack")
	sprite.animation_finished.connect(_on_animation_finished)


func set_direction(dir):
	direction = dir
	
func set_player(p):
	player = p

func _physics_process(delta):
	#velocity.x = speed * direction
	
	if player:
		var vertical = Input.get_axis("move_up", "move_down")
		var horizontal = Input.get_axis("move_left", "move_right")
		velocity.y = move_toward(velocity.y, vertical * speed, 800 * delta)
		velocity.x = move_toward(velocity.x, horizontal * speed, 800 * delta)
	
	
	move_and_slide()

func _on_animation_finished():
	queue_free()

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if player:
		player.end_projectile_control()
	queue_free()
