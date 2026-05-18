extends EnemyBase

@export var skeleton_knight_heavy_attack: PackedScene
@export var skeleton_knight_light_attack: PackedScene

@onready var skeleton_defeat_sfx : AudioStreamPlayer2D = $Defeat
@onready var skeleton_arise_sfx : AudioStreamPlayer2D = $Arise
@onready var skeleton_chase_sfx : AudioStreamPlayer2D = $Chase
@onready var skeleton_taunt_sfx : AudioStreamPlayer2D = $Taunt

signal skeleton_defeated

var attack_executed: bool = false
var damage_cooldown: float = 1.2
var is_taking_damage: bool = false
const WORLD_SCALE = 3.0

func _ready() -> void:
	super._ready()
	scale *= WORLD_SCALE

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += stats.gravity * _delta
	update_state_machine()
	move_and_slide()

func idle() -> void:
	if skeleton_chase_sfx.playing:
		skeleton_chase_sfx.stop()
	velocity.x = 0
	if can_see_player():
		skeleton_taunt_sfx.play()
		set_state(State.TAUNT)

func taunt() -> void:
	# if not playing taunt, play taunt
	velocity.x = 0
	set_collisions_enabled(false)

func get_enemy_separation() -> float:
	var push := 0.0

	for enemy in get_tree().get_nodes_in_group("skeleton_knights"):
		if enemy == self:
			continue

		var dist := global_position.distance_to(
			enemy.global_position
		)

		if dist < 40:
			push += sign(
				global_position.x - enemy.global_position.x
			)

	return push

func chase() -> void:
	if not skeleton_chase_sfx.playing:
		skeleton_chase_sfx.play()
		
	var player: Node2D = get_player()
	if player == null:
		set_state(State.IDLE)
		return

	var direction := global_position.direction_to(
		player.global_position
	)
	
	var dx : int = abs(player.global_position.x - global_position.x)
	
	if can_attack and dx <= 100:
		velocity.x = 0
		start_attack()
		return
	
	var move_dir := direction.x

	if should_turn_around():
		face_direction(facing_direction * -1)
		move_dir *= -1
	else:
		face_direction(-sign(move_dir))

	velocity.x = (
		move_dir * stats.move_speed
	) + (
		get_enemy_separation() * 60
	)

func start_attack() -> void:
	can_attack = false
	
	if randi_range(0, 1) == 0:
		set_attack(AttackType.LIGHT)
		#light_attack_sfx.play()
	else:
		set_attack(AttackType.HEAVY)
		#heavy_attack_sfx.play()
		#await heavy_attack_sfx.finished

	set_state(State.ATTACK)

func spawn_light_attack() -> void:
	var light_attack = skeleton_knight_light_attack.instantiate()
	get_parent().add_child(light_attack)
	
	light_attack.scale *= WORLD_SCALE
	light_attack.z_index = 10
	
	light_attack.global_position = light_spawn.global_position
	
	if facing_direction < 0:
		light_attack.scale.x *= -1
	
func spawn_heavy_attack() -> void:
	var heavy_attack = skeleton_knight_heavy_attack.instantiate()
	get_parent().add_child(heavy_attack)
	
	heavy_attack.scale *= WORLD_SCALE
	heavy_attack.z_index = 10
	
	heavy_attack.global_position = heavy_spawn.global_position
	
	if facing_direction < 0:
		heavy_attack.scale.x *= -1

func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.ATTACK:
			set_state(State.CHASE)
			can_attack = true
			attack_executed = false
		State.HIT:
			set_state(State.CHASE)
			can_attack = true
			attack_executed = false
		State.TAUNT:
			set_state(State.CHASE)
			set_collisions_enabled(true)
		State.DEFEAT:
			#await get_tree().create_timer(2.0).timeout
			# I need to await the minotaur jumping down, and then wake up
			fade_out_and_free()

func take_damage(_damage : int, _knockback: Vector2 = Vector2.ZERO) -> void:
	if is_taking_damage:
		return

	is_taking_damage = true

	if skeleton_chase_sfx.playing:
		skeleton_chase_sfx.stop()

	velocity.x = 0

	health = max(0, health - _damage)

	if health <= 0:
		skeleton_defeat_sfx.play()
		skeleton_defeated.emit()
		set_state(State.DEFEAT)
		return

	set_collisions_enabled(false)

	if health == 1:
		skeleton_taunt_sfx.play()
		set_state(State.TAUNT)
	else:
		set_state(State.HIT)

	await get_tree().create_timer(damage_cooldown).timeout

	set_collisions_enabled(true)

	is_taking_damage = false


func set_collisions_enabled(enabled: bool) -> void:
	if hurtbox:
		hurtbox.set_deferred("monitoring", enabled)
		hurtbox.set_deferred("monitorable", enabled)

	if hitbox:
		hitbox.set_deferred("monitoring", enabled)
		hitbox.set_deferred("monitorable", enabled)

func _on_animated_sprite_2d_frame_changed() -> void:
	if attack_executed:
		return
	match current_attack:
		AttackType.LIGHT:
			if sprite.frame == 3:
				attack_executed = true
				spawn_light_attack()
		AttackType.HEAVY:
			if sprite.frame == 2:
				attack_executed = true
				spawn_heavy_attack()
