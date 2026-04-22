extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spiders: Array[Node] = [
	$spider1,
	$spider2,
	$spider3,
	$spider4,
	$spider5,
	$spider6,
	$spider7
]

func _ready() -> void:
	for spider in spiders:
		spider.visible = false
		
func play_heal_sequence() -> void:
	# Frog hurt animation
	sprite.play("hurt")
	await sprite.animation_finished

	# Start frog healing animation
	sprite.play("heal")

	# Show spiders and start crawl animation at the same time
	for spider in spiders:
		spider.visible = true
		spider.get_node("AnimatedSprite2D").play("chase")

	# Wait until frog healing animation finishes
	await sprite.animation_finished

	# Hide spiders
	for spider in spiders:
		spider.visible = false
