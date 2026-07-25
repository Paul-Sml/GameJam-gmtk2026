extends Node2D

@export var speed: float = 500.0

func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func receive_attack(hitbox: Hitbox) -> void:
	queue_free()
