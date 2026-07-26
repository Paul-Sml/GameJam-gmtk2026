extends Area2D
class_name Hitbox

@export var damage: int = 1:
	get:
		if isPlayer:
			return abs(PlayerStats.resource.strength)
		return damage

@export var isPlayer: bool = false
@export var destroy_on_contact: bool = false
@export var push_from_center: bool = false

func _ready() -> void:
	monitoring = false
