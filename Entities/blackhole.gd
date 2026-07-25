extends Node2D
class_name Blackhole

@export var pull_strength: float = 800.0
@export var pull_radius: float = 400.0
@export var pull_strength_2: float = 800.0
@export var pull_radius_2: float = 600.0
@onready var sprite: Sprite2D = %Sprite
@onready var sprite_2: Sprite2D = %Sprite2
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func set_power(power: int) -> void:
	if power == 1:
		sprite.visible = true
	elif power == 2:
		sprite_2.visible = true
		pull_strength = pull_strength_2
		pull_radius = pull_radius_2
		collision_shape_2d.shape.radius = 32.0

func _physics_process(delta: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance < pull_radius and distance > 0:
			var direction: Vector2 = (global_position - enemy.global_position).normalized()
			var strength_factor: float = pow(1.0 - (distance / pull_radius), 2)
			enemy.global_position += direction * pull_strength * strength_factor * delta

func _on_timer_timeout() -> void:
	queue_free()
