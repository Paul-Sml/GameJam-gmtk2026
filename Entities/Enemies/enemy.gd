extends CharacterBody2D

@export var health: int = 3
@export var speed: float = 400.0
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_POWER: float = 1200

var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 3000 * delta)
		velocity = knockback_velocity
	else:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		velocity = direction * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func receive_attack(hitbox: Hitbox) -> void:
	var knockback_direction: Vector2 = Vector2.RIGHT.rotated(hitbox.rotation)
	knockback_velocity = knockback_direction * KNOCKBACK_POWER
	take_damage(hitbox.damage)
	
