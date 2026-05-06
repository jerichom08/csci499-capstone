extends CharacterBody2D

@export var spawn_offset: float = 60.0
@export var max_clones: int = 2
@export var clone_scale: float = 0.6
@export var gravity: float = 900.0

var clones_created := 0

func _physics_process(delta: float) -> void:
	# simple gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

	if Input.is_action_just_pressed("clone_enemy") and clones_created < max_clones:
		_clone_self()

func _clone_self() -> void:
	var clone := duplicate()
	if clone == null:
		return

	get_parent().add_child(clone)

	# spawn next to parent but keep same ground height
	clone.global_position = Vector2(
		global_position.x + spawn_offset * (clones_created + 1),
		global_position.y
	)

	# make clone smaller
	clone.scale = scale * clone_scale

	clones_created += 1
