extends EnemyBase

var was_defeated : bool = false
var can_attack : bool = false
var dx : int

func _ready() -> void:
	super._ready()
	set_state(State.REST)

func _physics_process(_delta: float) -> void:
	print(state_animations[current_state])
	update_state_machine()
	move_and_slide()

func handle_idle() -> void:
	set_state(State.IDLE)
	if can_see_player():
		handle_chase()

func handle_rest() -> void:
	set_state(State.REST)
	if can_see_player():
		handle_idle()

func handle_chase() -> void:
	set_state(State.CHASE)
	
	var player : Node2D = get_player()
	if player == null:
		velocity.x = 0
		return
	
	var dir : int = sign(player.global_position.x - global_position.x)
	face_direction(dir)
	
	velocity.x = dir * stats.move_speed

func handle_attack() -> void:
	#var player : Node2D = get_player()
	#if player == null:
		#dx = abs(player.global_position.x - global_position.x)
	#
	#if dx <= 200:
		#set_attack(AttackType.LIGHT)
	#else:
		#set_attack(AttackType.HEAVY)
	#
	#handle_chase()
	pass

func handle_hurt(damage : int) -> void:
	health = max(0, health - damage)
	if health == 0:
		handle_defeat()
		return
	
	set_state(State.HURT)
	handle_chase()

func handle_defeat() -> void:
	if was_defeated:
		set_state(State.DEFEAT)
	else:
		was_defeated = true
		handle_heal(stats.max_health)

func handle_heal(hp : int) -> void:
	if was_defeated:
		# Spawn spiders to revive completely
		return
	
	health = min(stats.max_health, health + hp)
	set_state(State.HEAL)

func take_damage(damage : int) -> void:
	handle_hurt(damage)
