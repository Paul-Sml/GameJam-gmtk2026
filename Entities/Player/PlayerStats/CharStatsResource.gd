extends Resource
class_name CharacterStatsResource

@export var name: String

@export var level: int = 1
@export var points_remaining: int = 0

@export var armor: int = 2
@export var strength: int = 2
@export var speed: int = 2

func level_down():
	level -= 1
	points_remaining -= 2
