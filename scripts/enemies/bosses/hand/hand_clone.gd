extends EnemyBase

@export var move_speed: float = 300.0
@export var gravity: float = 900.0
@export var lifetime: float = 2.0

var move_direction: Vector2 = Vector2.ZERO
var despawning := false

func _ready() -> void:
	super._ready()

	velocity = move_direction * move_speed

	# Auto despawn
	var tween = create_tween()
	tween.tween_interval(lifetime)
	tween.tween_callback(start_despawn)

func _physics_process(delta: float) -> void:
	if despawning:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func set_direction(direction: Vector2) -> void:
	move_direction = direction.normalized()

	if move_direction.x != 0:
		face_direction(sign(move_direction.x))

func hit(_damage: int) -> void:
	# Clone disappears immediately if hit
	start_despawn()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if despawning:
		return

	if area is Hurtbox:
		if area.owner == self:
			return

		area.take_hit(1)

		# Despawn after hitting player
		start_despawn()

func start_despawn() -> void:
	if despawning:
		return

	despawning = true

	if hitbox:
		hitbox.monitoring = false

	if hurtbox:
		hurtbox.monitoring = false

	fade_out_and_free()
