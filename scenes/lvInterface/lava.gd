extends TileMapLayer

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var lava: AudioStreamPlayer2D = $lava

var player_inside := false
var target_volume_db := -20.0  # quiet
var max_volume_db := 10.0       # loud
var fade_speed := 2.0
func _ready() -> void:
	animated_sprite_2d.play("default")


func _on_lava_sound_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true
		lava.play()


func _on_lava_sound_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false

		#lava.stop()



func _on_death_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$burnt.play()
		body.die()

func _process(delta: float) -> void:
	if player_inside:
		# increase volume toward max
		lava.volume_db = lerp(lava.volume_db, max_volume_db, fade_speed * delta)
	else:
		# decrease volume toward silence (or very low)
		lava.volume_db = lerp(lava.volume_db, -80.0, fade_speed * delta)

		# optional: stop when basically silent
		if lava.volume_db <= -79.0:
			lava.stop()
