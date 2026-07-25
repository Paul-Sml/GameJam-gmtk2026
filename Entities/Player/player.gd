extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Sprite2D

const INVINCIBILITY_DURATION: float = 1.0
var is_invincible: bool = false

const BLACKHOLE = preload("uid://c0cwug6l61ynw")

@export var speed: float = 300.0
@onready var hit_box: Hitbox = %HitBox
@onready var attack_cooldown: Timer = %Cooldown
const ATTACK_DURATION: float = 0.1

var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_POWER: float = 1200

const NEG_SPEED_MULTIPLIER: float = -3.0

func _physics_process(delta: float) -> void:
	movement(delta)
	attacking()

var teleport_distance_max: float:
	get:
		return 1000.0 if PlayerStats.resource.speed == -2 else 600.0

var teleport_charge_rate: float:
	get:
		return 1000.0 if PlayerStats.resource.speed == -2 else 600.0

var is_charging_teleport: bool = false
var teleport_hold_time: float = 0.0
var teleport_direction: Vector2 = Vector2.ZERO
var teleport_ghost: Sprite2D = null


func movement(delta: float) -> void:
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 3000 * delta)
		velocity = knockback_velocity
	elif PlayerStats.resource.speed > 0:
		var input_vector := Vector2.ZERO
		input_vector.x = Input.get_axis("left", "right")
		input_vector.y = Input.get_axis("up", "down")
		input_vector = input_vector.normalized()

		var player_speed: float = PlayerStats.resource.speed
		velocity = input_vector * speed * abs(player_speed)
	if PlayerStats.resource.speed < 0:
		velocity = Vector2.ZERO
		handle_teleport_charge(delta)

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		%Sprite2D2.flip_h = velocity.x < 0
		if velocity.x < 0:
			%Sprite2D2.position.x = abs(%Sprite2D2.position.x) * -1
		else:
			%Sprite2D2.position.x = abs(%Sprite2D2.position.x)
	move_and_slide()


enum TeleportKey {NONE, LEFT, RIGHT, UP, DOWN}
var active_teleport_key: TeleportKey = TeleportKey.NONE


func handle_teleport_charge(delta: float) -> void:
	if not is_charging_teleport:
		var pressed_key: TeleportKey = get_first_pressed_key()
		if pressed_key != TeleportKey.NONE:
			start_teleport_charge(pressed_key)
	else:
		teleport_hold_time += delta
		update_teleport_preview()

		if is_key_released(active_teleport_key):
			release_teleport()


func get_first_pressed_key() -> TeleportKey:
	if Input.is_action_just_pressed("left"):
		return TeleportKey.LEFT
	if Input.is_action_just_pressed("right"):
		return TeleportKey.RIGHT
	if Input.is_action_just_pressed("up"):
		return TeleportKey.UP
	if Input.is_action_just_pressed("down"):
		return TeleportKey.DOWN
	return TeleportKey.NONE


func is_key_released(key: TeleportKey) -> bool:
	match key:
		TeleportKey.LEFT:
			return Input.is_action_just_released("left")
		TeleportKey.RIGHT:
			return Input.is_action_just_released("right")
		TeleportKey.UP:
			return Input.is_action_just_released("up")
		TeleportKey.DOWN:
			return Input.is_action_just_released("down")
	return false


func key_to_direction(key: TeleportKey) -> Vector2:
	match key:
		TeleportKey.LEFT:
			return Vector2.LEFT
		TeleportKey.RIGHT:
			return Vector2.RIGHT
		TeleportKey.UP:
			return Vector2.UP
		TeleportKey.DOWN:
			return Vector2.DOWN
	return Vector2.ZERO


func start_teleport_charge(key: TeleportKey) -> void:
	is_charging_teleport = true
	active_teleport_key = key
	teleport_hold_time = 0.0
	teleport_direction = key_to_direction(key)

	teleport_ghost = Sprite2D.new()
	teleport_ghost.scale = Vector2(4, 4)
	teleport_ghost.texture = sprite.texture
	teleport_ghost.hframes = sprite.hframes
	teleport_ghost.vframes = sprite.vframes
	teleport_ghost.frame = sprite.frame
	teleport_ghost.modulate.a = 0.33
	get_parent().add_child(teleport_ghost)


func update_teleport_preview() -> void:
	var charge_distance: float = min(teleport_hold_time * teleport_charge_rate, teleport_distance_max)
	var target_position: Vector2 = global_position + teleport_direction * charge_distance

	teleport_ghost.global_position = target_position
	teleport_ghost.flip_h = teleport_direction.x < 0


func release_teleport() -> void:
	var origin_position: Vector2 = global_position
	var charge_distance: float = min(teleport_hold_time * teleport_charge_rate, teleport_distance_max)
	var target_position: Vector2 = origin_position + teleport_direction * charge_distance

	global_position = target_position
	resolve_teleport_overlap(teleport_direction)

	if origin_position.distance_to(global_position) > 200:
		spawn_blackhole(origin_position, PlayerStats.resource.speed)

	is_charging_teleport = false
	active_teleport_key = TeleportKey.NONE
	teleport_hold_time = 0.0

	if teleport_ghost:
		teleport_ghost.queue_free()
		teleport_ghost = null


func resolve_teleport_overlap(direction: Vector2) -> void:
	var step: float = 4.0
	var safety_counter: int = 300

	while test_move(global_transform, Vector2.ZERO) and safety_counter > 0:
		global_position -= direction * step
		safety_counter -= 1

func attacking() -> void:
	if PlayerStats.resource.strength == 0:
		return
	if Input.is_action_just_pressed("LMB") and attack_cooldown.is_stopped():
		hit_box.look_at(get_global_mouse_position())
		if PlayerStats.resource.strength == 0:
			pass
		if PlayerStats.resource.strength > 0:
			hit_box.scale = Vector2(.66, .66) * PlayerStats.resource.strength
			hit_box.visible = true
			hit_box.monitorable = true
			await get_tree().create_timer(ATTACK_DURATION).timeout # TODO : Real timer
			hit_box.visible = false
			hit_box.monitorable = false
			attack_cooldown.start()
		# if PlayerStats.resource.strength < 0:
		# 	spawn_blackhole(get_global_mouse_position(), PlayerStats.resource.strength)
		# 	attack_cooldown.wait_time = 1.0
		# 	attack_cooldown.start()

func spawn_blackhole(pos: Vector2, power: int) -> void:
	var blackhole: Blackhole = BLACKHOLE.instantiate()
	blackhole.global_position = pos
	get_tree().current_scene.add_child(blackhole)
	blackhole.set_power(abs(power))

func receive_attack(hitbox: Hitbox) -> void:
	if is_invincible:
		return
	start_invincibility()
	if !hitbox.destroy_on_contact:
		var knockback_direction: Vector2 = (global_position - hitbox.global_position).normalized()
		knockback_velocity = knockback_direction * KNOCKBACK_POWER
	take_damage()

func take_damage() -> void:
	if PlayerStats.current_armor == 0:
		print("defeat")
	elif PlayerStats.current_armor > 0:
		PlayerStats.current_armor -= 1
	elif PlayerStats.current_armor < 0:
		PlayerStats.current_armor += 1
		spawn_blackhole(self.global_position, PlayerStats.resource.armor)
	PlayerStats.armor_updated.emit(PlayerStats.current_armor)

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
