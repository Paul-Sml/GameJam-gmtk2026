extends CharacterBody2D

@export var health: int = 3
@export var speed: float = 100.0
var knockback_velocity: Vector2 = Vector2.ZERO

var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 2000 * delta)
		velocity = knockback_velocity
	else:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		velocity = direction * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print(health)
	if health <= 0:
		print("dead")

func receive_attack(hitbox: Hitbox) -> void:
	print (hitbox.rotation)
	var knockback_direction: Vector2 = Vector2.RIGHT.rotated(hitbox.rotation)
	knockback_velocity = knockback_direction * 600
	
