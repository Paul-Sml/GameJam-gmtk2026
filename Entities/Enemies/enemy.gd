extends CharacterBody2D
class_name Enemy

@onready var sprite: Sprite2D = %Sprite
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var progress_bar: ProgressBar = %ProgressBar

@export var health: int = 4
@export var speed: float = 250.0
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_POWER: float = 1200

var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	progress_bar.value = health
	progress_bar.max_value = health

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	nav_agent.target_position = player.global_position
	
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 3000 * delta)
		velocity = knockback_velocity
	else:
		#var direction: Vector2 = (player.global_position - global_position).normalized()
		var direction: Vector2 = global_position.direction_to(nav_agent.get_next_path_position())
		velocity = direction * speed
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
	progress_bar.value = health
	progress_bar.visible = true

func receive_attack(hitbox: Hitbox) -> void:
	var knockback_direction: Vector2 = Vector2.RIGHT.rotated(hitbox.rotation)
	knockback_velocity = knockback_direction * KNOCKBACK_POWER * (.5 * PlayerStats.resource.strength)
	take_damage(hitbox.damage)
	
