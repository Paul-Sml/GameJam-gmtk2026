extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Sprite2D

signal armor_updated(amount: int)
var resource: CharacterStatsResource
var current_armor: int = 2

const INVINCIBILITY_DURATION: float = 1.0
var is_invincible: bool = false

@export var speed: float = 600.0
@onready var hit_box: Hitbox = %HitBox
@onready var attack_cooldown: Timer = %Cooldown
const ATTACK_DURATION: float = 0.3

var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_POWER: float = 1200

func set_resource(player_resource: CharacterStatsResource) -> void:
	resource = player_resource
	current_armor = player_resource.armor

func _physics_process(delta: float) -> void:
	movement(delta)
	attacking()

func movement(delta: float) -> void:
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 3000 * delta)
		velocity = knockback_velocity
	else:
		var input_vector := Vector2.ZERO
		input_vector.x = Input.get_axis("left", "right")
		input_vector.y = Input.get_axis("up", "down")
		input_vector = input_vector.normalized()
		
		velocity = input_vector * speed
	move_and_slide()

func attacking() -> void:
	if Input.is_action_just_pressed("LMB") and attack_cooldown.is_stopped():
		attack_cooldown.start()
		hit_box.look_at(get_global_mouse_position())
		hit_box.visible = true
		hit_box.monitorable = true
		await get_tree().create_timer(ATTACK_DURATION).timeout # TODO : Real timer
		hit_box.visible = false
		hit_box.monitorable = false


func receive_attack(hitbox: Hitbox) -> void:
	if is_invincible:
		return
	start_invincibility()
	var knockback_direction: Vector2 = (global_position - hitbox.global_position).normalized()
	knockback_velocity = knockback_direction * KNOCKBACK_POWER
	take_damage()

func take_damage() -> void:
	if current_armor == 0:
		print("defeat")
	current_armor -= 1
	armor_updated.emit(current_armor)

func start_invincibility() -> void:
	is_invincible = true
	
	var blink_tween := create_tween()
	blink_tween.set_loops(int(INVINCIBILITY_DURATION / 0.16))
	blink_tween.tween_callback(func(): sprite.visible = false).set_delay(0.0)
	blink_tween.tween_interval(0.08)
	blink_tween.tween_callback(func(): sprite.visible = true)
	blink_tween.tween_interval(0.08)
	
	await get_tree().create_timer(INVINCIBILITY_DURATION).timeout
	is_invincible = false
	sprite.modulate.a = 1.0
