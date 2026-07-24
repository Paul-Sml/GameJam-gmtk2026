extends Node

signal armor_updated(amount: int)
	
@onready var resource: CharacterStatsResource = CharacterStatsResource.new()
var current_armor: int = 2

func reset_current_armor() -> void:
	current_armor = PlayerStats.resource.armor
	armor_updated.emit(current_armor)
