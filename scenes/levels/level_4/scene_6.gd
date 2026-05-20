extends Node2D

@onready var interact: Area2D = $interact
@onready var cauldron_label: Label = $interact/InteractionLabel

@onready var cat_meow: Area2D = $cat_meow
@onready var cat_label: Label = $cat_meow/InteractionLabel

@onready var c: Node2D = $c
@onready var cauldron_work: AnimatedSprite2D = $cauldron_work

@onready var ingredients_animation: AnimationPlayer = $ingredients/AnimationPlayer

@onready var boiling: AudioStreamPlayer2D = $boiling


var player_in_cauldron_range := false
var player_in_cat_range := false
var cauldron_interacted := false

func _ready() -> void:
	if SceneTransition.s:
		$JoanArea2D.show()
	else:
		$JoanArea2D.hide()
	cauldron_label.visible = false
	cat_label.visible = false
	$sparkles.visible = false
	$ingredients/egg_sprite.visible = false
	$ingredients/flour_sprite.visible = false
	$ingredients/milk_sprite.visible = false
	$ingredients/sugar_sprite.visible = false
	$cake2.visible = false
	$ingredients/cake.visible = false
	
	c.visible = true
	cauldron_work.visible = false

	interact.body_entered.connect(_on_cauldron_body_entered)
	interact.body_exited.connect(_on_cauldron_body_exited)

	cat_meow.body_entered.connect(_on_cat_body_entered)
	cat_meow.body_exited.connect(_on_cat_body_exited)

func _process(delta: float) -> void:
	if player_in_cauldron_range and Input.is_action_just_pressed("interaction") and not cauldron_interacted:
		cauldron_interacted = true

		c.visible = false
		cauldron_work.visible = true
		cauldron_work.play("default")
		boiling.play()
		
		
		play_ingredients_sequence()

		cauldron_label.visible = false

	if player_in_cat_range and Input.is_action_just_pressed("interaction"):
		cat_label.visible = false

func _on_cauldron_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player_intro"):
		return

	if not cauldron_interacted:
		player_in_cauldron_range = true
		cauldron_label.visible = true
		cauldron_label.text = "Press E to interact"

func _on_cauldron_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player_intro"):
		return

	player_in_cauldron_range = false
	cauldron_label.visible = false

func _on_cat_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player_intro"):
		return

	player_in_cat_range = true
	cat_label.visible = true
	cat_label.text = '" meow "'

func _on_cat_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player_intro"):
		return

	player_in_cat_range = false
	cat_label.visible = false
	
func play_ingredients_sequence() -> void:
	# Reset everything at the start
	$ingredients/egg_sprite.visible = true
	$ingredients/flour_sprite.visible = false
	$ingredients/sugar_sprite.visible = false
	$ingredients/milk_sprite.visible = false
	$ingredients/cake.visible = false
	$cake2.visible = false

	# Egg
	ingredients_animation.play("egg")
	await ingredients_animation.animation_finished

	# Flour
	$ingredients/egg_sprite.visible = false
	$ingredients/flour_sprite.visible = true

	ingredients_animation.play("flour_sprite")
	await ingredients_animation.animation_finished

	# Sugar
	$ingredients/flour_sprite.visible = false
	$ingredients/sugar_sprite.visible = true

	ingredients_animation.play("sugar")
	await ingredients_animation.animation_finished

	# Milk
	$ingredients/sugar_sprite.visible = false
	$ingredients/milk_sprite.visible = true

	ingredients_animation.play("milk")
	await ingredients_animation.animation_finished

	# Cake
	$ingredients/sugar_sprite.visible = false
	$ingredients/milk_sprite.visible = false
	$ingredients/cake.visible = true

	$sparkles.visible = true
	$sparkles.play("default")

	boiling.stop()
	cauldron_work.visible = false
	c.visible = true

	ingredients_animation.play("cake")
	$success.play()
	await ingredients_animation.animation_finished

	# Hide cake, then fade in cake2
	$ingredients/cake.visible = false

	$cake2.visible = true
	$cake2.modulate.a = 0.0
	$cake2.play("default") # candle animation

	var tween := create_tween()
	tween.tween_property($cake2, "modulate:a", 1.0, 0.4)

	await tween.finished

	# Cat says yayy
	$sparkles.visible = false
	cat_label.visible = true
	cat_label.text = '" yayy "'
	$victory.play()

	# Wait 3 seconds, then go to ending scene
	await get_tree().create_timer(3.0).timeout
	SceneTransition.change_scene_to("res://scenes/Fin.tscn")
