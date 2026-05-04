extends Sprite2D

signal button_pressed
signal button_released

@onready var sound_player: AudioStreamPlayer2D = $sound_player
func pressed():
	frame = 1
	sound_player.play()
	emit_signal("button_pressed")

func unpressed():
	frame = 0
	emit_signal("button_released")

func _ready():
	unpressed()

func _on_player_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	pressed()

func _on_player_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	unpressed()
