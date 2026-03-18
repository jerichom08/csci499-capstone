extends RayCast2D

func _physics_process(_delta):
	if not is_colliding():
		owner.turn_around()
