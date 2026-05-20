extends Node2D

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var next_button: Button = $Panel/NextButton
@onready var portrait: TextureRect = $Panel/Portrait
@onready var choice_box: VBoxContainer = $Panel/ChoiceBox
@onready var yes_button_1: Button = $Panel/ChoiceBox/YesButton1
@onready var yes_button_2: Button = $Panel/ChoiceBox/YesButton2
@onready var timer: Timer = $Timer

@onready var interaction_label: Label = $JoanArea2D/InteractionLabel


@export var joan_icon: Texture2D
@export var lilith_icon: Texture2D

var player_near_joan: bool = false
var dialogue_started: bool = false
var dialogue_index: int = 0
var current_text_finished: bool = false
var choices_done: bool = false
var current_dialogue: Array
var choosing: bool = false

var dialogue_array: Array = [
	{"speaker": "Joan", "text": ". L-Lilith? I’ve been searching for you..", "icon": "joan"},
	{"speaker": "Joan", "text": ". Can you believe that it’s been 15 years since the great war?", "icon": "joan"},
	{"speaker": "Joan", "text": ". I don’t think I’d ever have come close to defeating the demon king without you.", "icon": "joan"},
	{"speaker": "Lilith", "text": ". Joan, I thought you…", "icon": "lilith"},
	{"speaker": "Joan", "text": ". How could you just disappear without any trace!", "icon": "joan"},
	{"speaker": "Joan", "text": ". Did that kiss not mean anything to you?", "icon": "joan"},
	{"speaker": "Lilith", "text": ". After I felt your last breath, I couldn’t bear it anymore.", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". So I took Nyarla with me and warped to a dimension with no other soul.", "icon": "lilith"},
	{"speaker": "Joan", "text": ". I thought I was a goner too, but I was glad that I could feel your warmth one last time.", "icon": "joan"},
	{"speaker": "Joan", "text": ". But soon after, the saintess of Zenith brought me back to life, and I’ve been looking for you since.", "icon": "joan"},
	{"speaker": "Joan", "text": ". I'm glad I trusted my gut feeling that you'd at least visit the place my grave once resided...", "icon": "joan"},
	{"speaker": "Lilith", "text": ". Oh Joan, a world without you... everything in me shattered and I had no will to go on.", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". I hath locked myself away and was only able to bring myself to go out today for Nyarla's sake.", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". Joan, if only I knew…", "icon": "lilith"},
	{"speaker": "Joan", "text": ". Throughout our adventure, what kept me going was this.", "icon": "joan"},
	{"speaker": "Joan", "text": ". I wanted to properly propose to you after everything ended.", "icon": "joan"},
	{"speaker": "Lilith", "text": ". !!", "icon": "lilith"},
	{"speaker": "Joan", "text": ". So Lilith, will you marry me?", "icon": "joan"}
]

var after_choice_dialogue: Array = [
	{"speaker": "Lilith", "text": ". Joan! Of course i'd marry you I feel like my eyes and ears are decieving me", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". If this is a dream, I'm afraid I'd never want to wake up", "icon": "lilith"},
	{"speaker": "Joan", "text": ". I’ll make you the happiest you’ll ever be. I love you.", "icon": "joan"},
	{"speaker": "Lilith", "text": ". I love you too, my Joan.", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". Here, take my warping scroll...", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". This shall take you to my tower.", "icon": "lilith"},
	{"speaker": "Lilith", "text": ". I’m still in the middle of an errand. I’ll meet you home once it’s all sorted.", "icon": "lilith"},
	{"speaker": "Joan", "text": ". I’ll wait for you, my love. Be safe.", "icon": "joan"}
]


func _ready() -> void:
	interaction_label.visible = false
	$JoanArea2D/Joan.play("default")
	$scroll.hide()
	$hearts.hide()

	current_dialogue = dialogue_array
	panel.hide()
	choice_box.hide()

	timer.timeout.connect(_on_timer_timeout)
	next_button.pressed.connect(_on_next_button_pressed)
	yes_button_1.pressed.connect(_on_yes_pressed)
	yes_button_2.pressed.connect(_on_yes_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):
		if not dialogue_started and player_near_joan:
			start_dialogue()
		elif dialogue_started and not choice_box.visible:
			_advance_dialogue()


func start_dialogue() -> void:
	interaction_label.visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	dialogue_started = true
	dialogue_index = 0
	choices_done = false
	choosing = false
	current_dialogue = dialogue_array

	panel.show()
	show_dialogue()


func show_dialogue() -> void:
	timer.stop()

	if dialogue_index >= current_dialogue.size():
		if not choices_done:
			show_choices()
		else:
			hide_dialogue()
		return

	var current_line = current_dialogue[dialogue_index]

	panel.show()
	name_label.show()
	dialogue_label.show()
	portrait.show()
	next_button.show()
	choice_box.hide()

	name_label.text = current_line["speaker"]
	dialogue_label.text = current_line["text"]
	dialogue_label.visible_characters = 0
	current_text_finished = false

	if current_line["icon"] == "joan":
		portrait.texture = joan_icon
	elif current_line["icon"] == "lilith":
		portrait.texture = lilith_icon

	play_line_effect(current_line["text"])

	timer.start()


func play_line_effect(text: String) -> void:
	if text == ". Throughout our adventure, what kept me going was this.":
		$ring.play("default")
		$animate.play("ring up")
		$woa.play()

	if text == ". I’ll make you the happiest you’ll ever be. I love you.":
		$hearts.show()
		$hearts.play("default")
		$luv.play()
		hide_hearts_later()

	if text == ". Here, take my warping scroll...":
		$scroll.show()
		$scroll.play("default")
		$animate.play("scroll give")
		$give.play()


func hide_hearts_later() -> void:
	await get_tree().create_timer(3.0).timeout
	$hearts.hide()


func _on_timer_timeout() -> void:
	dialogue_label.visible_characters += 1

	if dialogue_label.visible_ratio >= 1:
		timer.stop()
		current_text_finished = true
	else:
		timer.start()


func _on_next_button_pressed() -> void:
	_advance_dialogue()


func _advance_dialogue() -> void:
	$click.play()

	if current_text_finished:
		dialogue_index += 1
		show_dialogue()
	else:
		dialogue_label.visible_characters = -1
		timer.stop()
		current_text_finished = true


func show_choices() -> void:
	timer.stop()

	panel.show()
	next_button.hide()
	choice_box.show()

	name_label.text = "Lilith"
	portrait.texture = lilith_icon
	dialogue_label.text = ""
	dialogue_label.visible_characters = -1

	yes_button_1.text = "Yes"
	yes_button_2.text = "YES (in caps bc no doom in this yuri)"

	yes_button_1.disabled = false
	yes_button_2.disabled = false


func _on_yes_pressed() -> void:
	if choosing:
		return

	choosing = true
	$click.play()

	yes_button_1.disabled = true
	yes_button_2.disabled = true
	choice_box.hide()
	next_button.hide()

	$animate.play("ring give")
	$give.play()
	await get_tree().create_timer(0.5).timeout

	choices_done = true
	current_dialogue = after_choice_dialogue
	dialogue_index = 0
	current_text_finished = false

	show_dialogue()


func hide_dialogue() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)
	
	SceneTransition.s = true
	timer.stop()
	panel.hide()
	choice_box.hide()
	dialogue_started = false
	$HiddenPlatform.show_platform()


func _on_dialogue_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near_joan = true
		interaction_label.visible = true
		interaction_label.text = "Press [ E ] to interact"


func _on_dialogue_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near_joan = false
		interaction_label.visible = false
		

func _on_nextscene(body: Node2D) -> void:
	SceneTransition.change_scene_to("res://scenes/levels/tutorial/scene_4.5.tscn")
