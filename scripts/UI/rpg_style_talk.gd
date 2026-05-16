extends CanvasLayer

@onready var face_texture = $Panel/FaceTexture
@onready var dialogue_text = $Panel/DialogueText


func _ready() -> void:
	hide_dialogue()


func show_dialogue(face: Texture2D, text: String) -> void:
	if face_texture:
		face_texture.texture = face

	if dialogue_text:
		dialogue_text.text = text

	visible = true


func hide_dialogue() -> void:
	visible = false
