extends RayCast2D

@export var owner_body: CharacterBody2D

var last_seen: Node2D = null
var lose_timer := 0.2
var timer := 0.0

func _physics_process(delta):
	if is_colliding():
		var collider = get_collider()

		if collider and collider.is_in_group("player"):
			timer = lose_timer

			if collider != last_seen:
				last_seen = collider
				if owner_body and owner_body.has_method("on_player_detected"):
					owner_body.on_player_detected(collider)
			return

	# not colliding with player
	timer -= delta

	if timer <= 0 and last_seen:
		if owner_body and owner_body.has_method("on_player_lost"):
			owner_body.on_player_lost()
		last_seen = null
