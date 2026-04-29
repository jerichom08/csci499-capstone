#"""
#CharacterBody2D
#├─AnimatedSprite2D ("chase", "default_attack", "defeat", "hurt", "idle", "rest")
#├─CollisionShape2D
#├─Hurtbox
#├─VisionRay (-100, 0)
#└─WallRay (-20, 0)
#"""
#extends EnemyBase
#
#func _ready() -> void:
	#super._ready()
	#health = 1
	#set_state(State.REST)
	#face_direction(facing_direction)
#
#func _physics_process(_delta: float) -> void:
	#update_state_machine()
	#move_and_slide()
#
#func handle_rest() -> void:
	#velocity = Vector2.ZERO
	#
	#var seen_player := get_seen_player()
	#if seen_player != null:
		#target_player = seen_player
		#set_state(State.CHASE)
#
#func handle_chase() -> void:
	#var seen_player := get_seen_player()
#
	#if seen_player == null:
		#target_player = null
		#velocity.x = 0
		#set_state(State.RETURN)
		#return
#
	#target_player = seen_player
#
	#var dir: int = sign(target_player.global_position.x - global_position.x)
#
	#if dir != 0:
		#face_direction(dir)
#
	#if should_turn_around():
		#velocity.x = 0
		#return
#
	#velocity.x = dir * stats.move_speed
#
#func handle_return() -> void:
	#var seen_player := get_seen_player()
	#if seen_player != null:
		#target_player = seen_player
		#set_state(State.CHASE)
		#return
#
	#var to_spawn := spawn_position - global_position
	#var distance := to_spawn.length()
#
	#if distance < 2.0:
		#velocity.x = 0
		#set_state(State.REST)
		#return
#
	#var dir : int = sign(to_spawn.x)
#
	#if dir != 0:
		#face_direction(dir)
#
	#if should_turn_around():
		#velocity.x = 0
		#return
#
	#velocity.x = dir * stats.move_speed
#
#func handle_hurt() -> void:
	#velocity.x = 0
#
#func handle_defeat() -> void:
	#velocity.x = 0
#
#func take_damage(amount : int) -> void:
	#handle_hurt()

extends EnemyBase

func _ready() -> void:
	super._ready()
	sprite.modulate.a = 0.0   # start invisible
	set_state(State.IDLE)
	fade_in()

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 0.4)

func fade_out_and_free() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
