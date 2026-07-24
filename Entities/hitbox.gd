extends Area2D
class_name Hitbox

@export var damage: int = 1:
	get:
		if isPlayer:
			return PlayerStats.resource.strength
		return damage

@export var isPlayer: bool = false

func _ready() -> void:
	monitoring = false
