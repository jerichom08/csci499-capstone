extends Control

#nide references
@onready var label: Label = $Label
@onready var timer: Timer = $Timer
@onready var button: Button =$Button
#variables

var dialogue_array : Array = [
	 """ "It’s finally Nyarla’s birthday today" """,
	 """ "And I really wanted to bake him a cake" """,
	 """ "But I seem to be missing some ingredients" """
]
var dialogue_index : int  = 0:
	set(value):
		dialogue_index = value
		
		label.visible_characters = -1

#initializations
func _ready() -> void:
	label.text = ""
	timer.timeout.connect(animate_label)
	
	#animate_label()

func animate_label() -> void:
	if dialogue_index >=  dialogue_array.size():
		label.hide()
		button.hide()
		return
		#hide button and text
		
	label.text = dialogue_array[dialogue_index]
	label.visible_characters+=1
	if label.visible_ratio == 1:
		dialogue_index+=1
	else:
		timer.start()


func _on_button_pressed() -> void:
	if timer.is_stopped():
		animate_label()
	else:
		dialogue_index+=1
		timer.stop()
