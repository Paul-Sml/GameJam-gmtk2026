extends Area2D
class_name Hitbox

@export var damage: int = 1

func _ready() -> void:
	collision_layer = 2
	monitoring = false
