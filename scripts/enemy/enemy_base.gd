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

@export var stats : Stats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = get_node_or_null("Hitbox")
@onready var vision_ray: RayCast2D = get_node_or_null("VisionRay")
@onready var wall_ray: RayCast2D = get_node_or_null("WallRay")
@onready var ledge_ray: RayCast2D = get_node_or_null("LedgeRay")

# --- Runtime Stats ---
var health : int
var facing_direction: int = 0 # 1 = right, -1 = left, 0 = default
var is_dead: bool = false
var spawn_position: Vector2

# --- Player ---
var target_player: Node2D = null

enum State {
	IDLE, 
	REST,
	RETURN, 
	CHASE, 
	ATTACK, 
	HURT, 
	DEFEAT,
	HEAL
}
var state_animations := {
	State.IDLE : "idle",
	State.REST : "rest",
	State.RETURN : "chase",
	State.CHASE : "chase",
	State.ATTACK : "attack",
	State.HURT : "hurt",
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
	if stats == null:
		push_error("EnemyBase requires a Stats resource.")
		return
	
	health = stats.max_health
	spawn_position = global_position
	if stats.faces_left: face_direction(-1)

func set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	if current_state != State.ATTACK:
		current_attack = AttackType.NONE

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
		State.HURT:
			hurt(0)
		State.DEFEAT:
			defeat()
		State.HEAL:
			heal(0)
		_:
			push_warning("Unhandled state: %s" % current_state)

func play_state_animation() -> void:
	if not state_animations.has(current_state):
		return
	
	var anim_name: String = state_animations[current_state]
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func play_attack_animation() -> void:
	if not attack_animations.has(current_attack):
		return
	
	var anim_name: String = attack_animations[current_attack]
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func idle() -> void:
	play_state_animation()
	handle_idle()

func rest() -> void:
	play_state_animation()
	handle_rest()

func return_to_spawn() -> void:
	play_state_animation()
	handle_return()

func chase() -> void:
	play_state_animation()
	handle_chase()

func attack() -> void:
	match current_attack:
		AttackType.NONE:
			push_warning("No Attack Selected")
		AttackType.DEFAULT, AttackType.LIGHT, AttackType.HEAVY:
			play_attack_animation()
		_:
			push_warning("Invalid Attack Type Selected")
	handle_attack()

func hurt(damage : int) -> void:
	play_state_animation()
	handle_hurt(damage)

func defeat() -> void:
	play_state_animation()
	handle_defeat()

func heal(hp : int) -> void:
	play_state_animation()
	handle_heal(hp)

func handle_idle() -> void:
	pass
func handle_rest() -> void:
	pass
func handle_return() -> void:
	pass
func handle_chase() -> void:
	pass
func handle_attack() -> void:
	pass
func handle_hurt(damage : int) -> void:
	pass
func handle_defeat() -> void:
	pass
func handle_heal(hp : int) -> void:
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

func face_direction(direction: float) -> void:
	if direction == 0:
		return
	
	if facing_direction != direction:
		facing_direction = direction
		
		sprite.flip_h = facing_direction < 0  
	
	# Update rays
	if vision_ray:
		vision_ray.target_position.x = abs(vision_ray.target_position.x) * facing_direction
	if wall_ray:
		wall_ray.target_position.x = abs(wall_ray.target_position.x) * facing_direction
	if ledge_ray:
		ledge_ray.position.x = abs(ledge_ray.position.x) * facing_direction
