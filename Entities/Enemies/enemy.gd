extends CharacterBody2D
class_name Enemy

@onready var a_sprite: AnimatedSprite2D = %Sprite
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var progress_bar: ProgressBar = %ProgressBar

@export var health: int = 4
@export var speed: float = 250.0
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_POWER: float = 1200
@export var bounce_factor: float = 0.3

var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	progress_bar.value = health
	progress_bar.max_value = health
	
func update_animation() -> void:
	if knockback_velocity.length() > 0 or velocity == Vector2.ZERO:
		a_sprite.speed_scale = 0.0
	else:
		a_sprite.speed_scale = abs(PlayerStats.resource.speed) if PlayerStats.resource.speed != 0 else 1.0

	if a_sprite.animation != "default":
		a_sprite.play("default")
	elif not a_sprite.is_playing():
		a_sprite.play("default")
		
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
		a_sprite.flip_h = velocity.x < 0
	move_and_slide()
	if knockback_velocity.length() > 0:
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var collider = collision.get_collider()

			if collider is StaticBody2D:
				knockback_velocity = knockback_velocity.bounce(collision.get_normal()) * bounce_factor
			elif collider is Enemy and collider != self:
				collider.receive_push(knockback_velocity * bounce_factor)
	update_animation()

func receive_push(push_velocity: Vector2) -> void:
	knockback_velocity += push_velocity

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
	progress_bar.value = health
	progress_bar.visible = true

func receive_attack(hitbox: Hitbox) -> void:
	if !hitbox.destroy_on_contact:
		if hitbox.push_from_center:
			var knockback_direction: Vector2 = hitbox.global_position.direction_to(global_position)
			knockback_velocity = knockback_direction * KNOCKBACK_POWER * 4
		else:
			var knockback_direction: Vector2 = Vector2.RIGHT.rotated(hitbox.rotation)
			knockback_velocity = knockback_direction * KNOCKBACK_POWER
		if PlayerStats.resource.strength == 1:
			knockback_velocity *= .75
		if PlayerStats.resource.strength < 0:
			knockback_velocity *= 2
	take_damage(hitbox.damage)
