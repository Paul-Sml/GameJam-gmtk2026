extends CharacterBody2D
class_name Player

@onready var a_sprite: AnimatedSprite2D = $Sprite2D
@onready var ghost: Sprite2D = %ghost
@onready var attack_anim: AnimatedSprite2D = %AttackAnim

const INVINCIBILITY_DURATION: float = 1.0
var is_invincible: bool = false

const BLACKHOLE = preload("uid://c0cwug6l61ynw")
const EXPLOSION = preload("uid://dq4ocgoecg3de")
const SELF_PROJECTILE = preload("uid://ptt048iamwv2")

var speed: float:
	get:
		return 500.0 if PlayerStats.resource.speed == 2 else 300.0
@onready var hit_box: Hitbox = %HitBox
@onready var attack_cooldown: Timer = %Cooldown
const ATTACK_DURATION: float = 0.1

var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_POWER: float = 1200

const NEG_SPEED_MULTIPLIER: float = -3.0

func _physics_process(delta: float) -> void:
	attacking()
	movement(delta)

func movement(delta: float) -> void:
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 3000 * delta)
		velocity = knockback_velocity
	elif PlayerStats.resource.speed > 0:
		var input_vector := Vector2.ZERO
		input_vector.x = Input.get_axis("left", "right")
		input_vector.y = Input.get_axis("up", "down")
		input_vector = input_vector.normalized()

		velocity = input_vector * speed
	if PlayerStats.resource.speed < 0:
		velocity = Vector2.ZERO
		handle_dash(delta)
		update_sprite_facing()
		return

	update_animation()
	update_sprite_facing()
		
	move_and_slide()

func update_animation() -> void:
	if knockback_velocity.length() > 0 or velocity == Vector2.ZERO:
		a_sprite.speed_scale = 0.0
	else:
		a_sprite.speed_scale = abs(PlayerStats.resource.speed) if PlayerStats.resource.speed != 0 else 1.0

	if a_sprite.animation != "default":
		a_sprite.play("default")
	elif not a_sprite.is_playing():
		a_sprite.play("default")

func update_sprite_facing() -> void:
	if velocity.x == 0:
		return

	a_sprite.flip_h = velocity.x < 0
	%Sprite2D2.flip_h = velocity.x < 0
	%Sprite2D2.position.x = abs(%Sprite2D2.position.x) * (1 if velocity.x >= 0 else -1)

var dash_distance_max: float:
	get:
		#return 450.0 if PlayerStats.resource.speed == -2 else 300.0
		return 420
@export var dash_speed: float = 2000.0
@export var dash_cooldown_duration: float = 0.4
@export var ghost_spawn_interval: float = 0.035

var dash_cooldown: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_traveled: float = 0.0
var ghost_timer: float = 0.0


func handle_dash(delta: float) -> void:
	if dash_cooldown > 0:
		dash_cooldown -= delta

	if is_dashing:
		perform_dash_step(delta)
		return

	if dash_cooldown > 0:
		return

	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("left"):
		direction = Vector2.LEFT
	elif Input.is_action_just_pressed("right"):
		direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("up"):
		direction = Vector2.UP
	elif Input.is_action_just_pressed("down"):
		direction = Vector2.DOWN

	if direction != Vector2.ZERO:
		start_dash(direction)


func start_dash(direction: Vector2) -> void:
	is_dashing = true
	dash_direction = direction
	dash_traveled = 0.0
	ghost_timer = 0.0
	is_invincible = true
	a_sprite.modulate = Color(0.55, 0.9, 1.0, 1.0)*3
	
	spawn_delayed_dash_projectile(direction, global_position)

@export var projectile_spawn_offset: float = 128.0
@export var projectile_convergence_angle: float = 14.0

func spawn_delayed_dash_projectile(direction: Vector2, start_position: Vector2) -> void:
	await get_tree().create_timer(0.25).timeout
	
	var perpendicular: Vector2 = direction.rotated(PI / 2)
	var travel_distance: float = dash_distance_max - 64
	
	var offsets: Array[float] = [-projectile_spawn_offset, 0.0, projectile_spawn_offset]
	
	for offset in offsets:
		var spawn_position: Vector2 = start_position + perpendicular * offset
		
		# Angle vers le centre proportionnel au décalage (signe opposé à l'offset pour converger)
		var angle_sign: float = -sign(offset)
		var travel_direction: Vector2 = direction.rotated(deg_to_rad(projectile_convergence_angle * angle_sign))
		
		var projectile := SELF_PROJECTILE.instantiate()
		projectile.rotation = travel_direction.angle()
		get_parent().add_child(projectile)
		projectile.global_position = spawn_position
		
		if projectile.has_method("launch"):
			projectile.launch(travel_direction, travel_distance, dash_speed)

func perform_dash_step(delta: float) -> void:
	var move_amount: float = dash_speed * delta
	var remaining_distance: float = dash_distance_max - dash_traveled
	move_amount = min(move_amount, remaining_distance)

	global_position += dash_direction * move_amount
	dash_traveled += move_amount

	ghost_timer += delta
	if ghost_timer >= ghost_spawn_interval:
		ghost_timer = 0.0
		spawn_dash_ghost()

	if dash_traveled >= dash_distance_max:
		end_dash()

func end_dash() -> void:
	is_dashing = false
	is_invincible = false
	velocity = Vector2.ZERO
	dash_cooldown = dash_cooldown_duration
	resolve_dash_overlap(dash_direction)
	check_post_dash_overlap()
	a_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func check_post_dash_overlap() -> void:
	for area in $HurtBox.get_overlapping_areas():
		if area is Hitbox:  # adapte selon ta structure
			receive_attack(area)

func resolve_dash_overlap(direction: Vector2) -> void:
	var step: float = 4.0
	var safety_counter: int = 300

	while test_move(global_transform, Vector2.ZERO) and safety_counter > 0:
		global_position -= direction * step
		safety_counter -= 1


func spawn_dash_ghost() -> void:
	print("Ghost texture: ", ghost.texture)
	var ghost_sprite := Sprite2D.new()
	ghost_sprite.texture = ghost.texture
	ghost_sprite.hframes = ghost.hframes
	ghost_sprite.vframes = ghost.vframes
	ghost_sprite.frame = ghost.frame
	ghost_sprite.flip_h = ghost.flip_h
	ghost_sprite.scale = Vector2(4, 4)
	ghost_sprite.modulate = Color(0.55, 0.9, 1.0, 1.0)*3
	ghost_sprite.modulate.a = 0.5
	get_parent().add_child(ghost_sprite)
	ghost_sprite.global_position = global_position
	print("Ghost added, parent: ", get_parent().name, " | position: ", ghost_sprite.global_position, " | in tree: ", ghost_sprite.is_inside_tree())
	var tween := ghost_sprite.create_tween()
	tween.tween_property(ghost_sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(ghost_sprite.queue_free)

const ATTACK_LUNGE_POWER: float = 600.0

func attacking() -> void:
	if PlayerStats.resource.strength == 0:
		return
	if Input.is_action_just_pressed("LMB") and attack_cooldown.is_stopped():
		attack_cooldown.start()
		hit_box.look_at(get_global_mouse_position())
		if PlayerStats.resource.strength == 0:
			#Clignotage
			return

		hit_box.scale = Vector2(.75, .75) if abs(PlayerStats.resource.strength) == 1 else Vector2(1, 1)
		hit_box.visible = true
		attack_anim.play("default")
		hit_box.monitorable = true

		var attack_direction: Vector2 = Vector2.RIGHT.rotated(hit_box.rotation)
		#knockback_velocity += attack_direction * ATTACK_LUNGE_POWER

		await get_tree().create_timer(ATTACK_DURATION).timeout # TODO : Real timer
		hit_box.visible = false
		hit_box.monitorable = false

func spawn_blackhole(pos: Vector2, power: int) -> void:
	var blackhole: Blackhole = BLACKHOLE.instantiate()
	blackhole.global_position = pos
	get_tree().current_scene.add_child(blackhole)
	blackhole.set_power(abs(power))

func spawn_explosion(pos: Vector2) -> void:
	var explosion: Node2D = EXPLOSION.instantiate()
	explosion.global_position = pos
	get_tree().current_scene.add_child(explosion)

func spawn_neg_shield() -> void:
	var level: Level = get_parent()
	if level is not Level:
		push_error("Player is not a child of a Level node.")
		return
	level.spawn_neg_shield()
	
func receive_attack(hitbox: Hitbox) -> void:
	if is_invincible:
		return
	start_invincibility()
	if !hitbox.destroy_on_contact or !PlayerStats.resource.armor < 0:
		var knockback_direction: Vector2 = (global_position - hitbox.global_position).normalized()
		knockback_velocity = knockback_direction * KNOCKBACK_POWER
	take_damage()

func take_damage() -> void:
	if PlayerStats.current_armor == 0:
		PlayerStats.defeat.emit()
	elif PlayerStats.current_armor > 0:
		PlayerStats.current_armor -= 1
	elif PlayerStats.current_armor < 0:
		PlayerStats.current_armor += 1
		spawn_explosion(self.global_position)
		spawn_neg_shield()
	PlayerStats.armor_updated.emit(PlayerStats.current_armor)

func start_invincibility() -> void:
	is_invincible = true
	
	var blink_tween := create_tween()
	blink_tween.set_loops(int(INVINCIBILITY_DURATION / 0.16))
	blink_tween.tween_callback(func(): a_sprite.visible = false).set_delay(0.0)
	blink_tween.tween_interval(0.08)
	blink_tween.tween_callback(func(): a_sprite.visible = true)
	blink_tween.tween_interval(0.08)
	
	await get_tree().create_timer(INVINCIBILITY_DURATION).timeout
	is_invincible = false
	a_sprite.modulate.a = 1.0
	
	check_post_dash_overlap()
