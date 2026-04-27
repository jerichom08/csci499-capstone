extends EnemyBase

@export var frog_spit_attack: PackedScene
@export var frog_tongue_attack: PackedScene
@export var spider_scene: PackedScene

var active_spiders: Array[Node2D] = []
var was_defeated: bool = false
var spiders_spawned : bool = false
var attack_executed : bool = false
const WORLD_SCALE = 3.0

func set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	if new_state == State.ATTACK:
		attack_executed = false
	else:
		current_attack = AttackType.NONE
	
	play_animation()

func _ready() -> void:
	super._ready()
	set_state(State.REST)
	sprite.frame_changed.connect(_on_sprite_frame_changed)

func _physics_process(_delta: float) -> void:
	update_state_machine()
	move_and_slide()

func idle() -> void:
	set_state(State.IDLE)
	if can_see_player():
		set_state(State.CHASE)

func rest() -> void:
	set_state(State.REST)
	if can_see_player():
		set_state(State.CHASE)

func chase() -> void:
	set_state(State.CHASE)
	
	var player: Node2D = get_player()
	if player == null:
		velocity.x = 0
		return
	
	var dir : int = sign(player.global_position.x - global_position.x)
	face_direction(dir)
	
	var dx : int = abs(player.global_position.x - global_position.x)

	if can_attack and dx <= 400:
		velocity.x = 0
		start_attack(dx)
		return
	
	if should_turn_around():
		velocity.x = 0
	else:
		velocity.x = dir * stats.move_speed

func start_attack(dx: int) -> void:
	print(dx)
	can_attack = false
	#attack_executed = false
	
	if dx > 300:
		set_attack(AttackType.HEAVY)
	else:
		set_attack(AttackType.LIGHT)
	
	set_state(State.ATTACK)

func hit(damage: int) -> void:
	set_state(State.HIT)
	
	velocity.x = 0
	health = max(0, health - damage)
	
	if health == 0:
		defeat()

func defeat() -> void:
	if was_defeated:
		set_state(State.DEFEAT)
	else:
		was_defeated = true
		heal(stats.max_health)

func heal(hp: int) -> void:
	if was_defeated:
		spawn_spiders()
	
	health = min(stats.max_health, health + hp)
	set_state(State.HEAL)

func spawn_spiders() -> void:
	if spiders_spawned:
		return
	
	spiders_spawned = true
	for i in range(50):
		var spider = spider_scene.instantiate()
		get_parent().add_child(spider)

		spider.face_direction(1)
		spider.scale *= WORLD_SCALE
		
		# Slight random spread
		var offset := Vector2(randf_range(-100, 100), randf_range(0, 200))
		spider.global_position = global_position + offset
		
		active_spiders.append(spider)

func clear_spiders() -> void:
	for spider in active_spiders:
		if is_instance_valid(spider):
			spider.fade_out_and_free()
	
	active_spiders.clear()
	spiders_spawned = false

func take_damage(damage: int) -> void:
	hit(damage)

func spawn_light_attack() -> void:
	var light_attack = frog_spit_attack.instantiate()
	get_parent().add_child(light_attack)
	
	light_attack.scale *= WORLD_SCALE
	light_attack.z_index = 10
	
	light_attack.global_position = light_spawn.global_position
	
	if facing_direction < 0:
		light_attack.scale.x *= -1

func spawn_heavy_attack() -> void:
	var heavy_attack = frog_tongue_attack.instantiate()
	get_parent().add_child(heavy_attack)
	
	heavy_attack.scale *= WORLD_SCALE
	heavy_attack.z_index = 10
	
	heavy_attack.global_position = heavy_spawn.global_position
	
	if facing_direction < 0:
		heavy_attack.scale.x *= -1
	
func _on_animation_finished() -> void:
	match current_state:
		State.ATTACK:
			reset_attack_cooldown()
			set_state(State.CHASE)
		
		State.HIT:
			set_state(State.CHASE)

		State.HEAL:
			clear_spiders()
			set_state(State.CHASE)

		State.DEFEAT:
			pass

func _on_sprite_frame_changed() -> void:
	if current_state != State.ATTACK:
		return
	
	if attack_executed:
		return
	
	if current_attack == AttackType.LIGHT:
		if sprite.animation == "light_attack" and sprite.frame == 7:
			attack_executed = true
			spawn_light_attack()
	
	elif current_attack == AttackType.HEAVY:
		if sprite.animation == "heavy_attack" and sprite.frame == 2:
			attack_executed = true
			spawn_heavy_attack()

func reset_attack_cooldown() -> void:
	await get_tree().create_timer(stats.attack_cooldown).timeout
	can_attack = true
