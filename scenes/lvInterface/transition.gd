extends CanvasLayer

@onready var fade: ColorRect = $Fade

var fade_time = 0.3
var is_transitioning = false

var respawn_from_death = false

func _ready():
	fade.modulate.a = 0.0

func fade_out():
	if is_transitioning:
		return
	is_transitioning = true

	var t = create_tween()
	t.tween_property(fade, "modulate:a", 1.0, fade_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	await t.finished


func fade_in():
	var t = create_tween()
	t.tween_property(fade, "modulate:a", 0.0, fade_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	await t.finished
	is_transitioning = false


func reload_scene_with_fade():
	await fade_out()
	get_tree().reload_current_scene()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	await fade_in()
