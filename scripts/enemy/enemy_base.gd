"""
CharacterBody2D
├─AnimatedSprite2D (Core)
├─CollisionShape2D (Core)
├─Hurtbox (Core)
├─Hitbox (Optional)
├─VisionRay (Optional)
├─WallRay (Optional)
└─LedgeRay(Optional)
"""

class_name EnemyBase extends CharacterBody2D

# --- Core Stats ---
@export var stats : Stats

# --- Core Components ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Hurtbox = $Hurtbox

# --- Optional Components ---
@onready var hitbox: Hitbox = get_node_or_null("Hitbox")
@onready var vision_ray: RayCast2D = get_node_or_null("VisionRay")
@onready var wall_ray: RayCast2D = get_node_or_null("WallRay")
@onready var ledge_ray: RayCast2D = get_node_or_null("LedgeRay")
@onready var light_spawn: Marker2D = get_node_or_null("LightSpawn")
@onready var heavy_spawn: Marker2D = get_node_or_null("HeavySpawn")

# --- Runtime Stats ---
var health : int
var facing_direction: int = 1 # 1 = right, -1 = left
var is_dead: bool = false
var spawn_position: Vector2
var can_attack : bool = true

enum State {
	IDLE,
	REST,
	RETURN,
	CHASE,
	ATTACK,
	HIT,
	DEFEAT,
	HEAL
}
var state_animations := {
	State.IDLE : "idle",
	State.REST : "rest",
	State.RETURN : "chase",
	State.CHASE : "chase",
	State.ATTACK : "attack",
	State.HIT : "hit",
	State.DEFEAT : "defeat",
	State.HEAL : "heal"
}
enum AttackType {
	NONE,
	DEFAULT,
	LIGHT,
	HEAVY
}
var attack_animations := {
	AttackType.DEFAULT : "default_attack",
	AttackType.LIGHT : "light_attack",
	AttackType.HEAVY : "heavy_attack"
}
var current_state : State = State.IDLE
var current_attack: AttackType = AttackType.NONE

func _ready() -> void:
	health = stats.max_health
	spawn_position = global_position
	if stats.faces_left: face_direction(-1)
	sprite.animation_finished.connect(_on_animation_finished)

func set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	if current_state != State.ATTACK:
		current_attack = AttackType.NONE
	
	play_animation()

func set_attack(new_attack: AttackType) -> void:
	current_attack = new_attack

func update_state_machine() -> void:
	match current_state:
		State.IDLE:
			idle()
		State.REST:
			rest()
		State.RETURN:
			return_to_spawn()
		State.CHASE:
			chase()
		State.ATTACK:
			attack()
		State.HIT:
			hit(0)
		State.DEFEAT:
			defeat()
		State.HEAL:
			heal(0)
		_:
			push_warning("Unhandled state: %s" % current_state)

func play_animation() -> void:
	var anim_name := ""
	
	if current_state == State.ATTACK:
		anim_name = attack_animations.get(current_attack, "")
	else:
		anim_name = state_animations.get(current_state, "")
	
	if anim_name != "" and sprite.animation != anim_name:
		sprite.play(anim_name)

func _on_animation_finished() -> void:
	match current_state:
		State.HIT:
			set_state(State.CHASE)
		State.ATTACK:
			set_state(State.CHASE)
		State.HEAL:
			set_state(State.CHASE)

func idle() -> void:
	pass

func rest() -> void:
	pass

func return_to_spawn() -> void:
	pass

func chase() -> void:
	pass

func attack() -> void: 
	pass

func hit(_damage : int) -> void:
	pass

func defeat() -> void:
	pass

func heal(_hp : int) -> void:
	pass

func get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null

func get_seen_player() -> Node2D:
	if vision_ray == null:
		return null
	
	if not vision_ray.is_colliding():
		return null
	
	var collider = vision_ray.get_collider()
	if collider == null:
		return null
	
	var node = collider as Node
	while node != null:
		if node.is_in_group("player"):
			return node as Node2D
		node = node.get_parent()
	
	return null

func can_see_player() -> bool:
	return get_seen_player() != null

func is_wall_ahead() -> bool:
	if wall_ray == null:
		return false
	return wall_ray.is_colliding()

func is_about_to_walk_off_ledge() -> bool:
	if ledge_ray == null:
		return false
	return not ledge_ray.is_colliding()

func should_turn_around() -> bool:
	return is_wall_ahead() or is_about_to_walk_off_ledge()

func face_direction(direction: int) -> void:
	if direction == 0:
		return
	
	if facing_direction != direction:
		facing_direction = direction
		
		sprite.flip_h = facing_direction < 0  
	
	# Update Attack Spawns
	if light_spawn:
		light_spawn.position.x = abs(light_spawn.position.x) * facing_direction
	if heavy_spawn:
		heavy_spawn.position.x = abs(heavy_spawn.position.x) * facing_direction
	
	# Update rays
	if vision_ray:
		vision_ray.target_position.x = abs(vision_ray.target_position.x) * facing_direction
	if wall_ray:
		wall_ray.target_position.x = abs(wall_ray.target_position.x) * facing_direction
	if ledge_ray:
		ledge_ray.position.x = abs(ledge_ray.position.x) * facing_direction
