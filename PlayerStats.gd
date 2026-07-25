extends Node

var stats_points: Dictionary[int, CompressedTexture2D] = {
	2: preload("res://Assets/LevelDownMenu/StatLvl2.png"),
	1: preload("res://Assets/LevelDownMenu/StatLvl1.png"),
	0: preload("res://Assets/LevelDownMenu/StatLvl0.png"),
	-1: preload("res://Assets/LevelDownMenu/StatLvl-1.png"),
	-2: preload("res://Assets/LevelDownMenu/StatLvl-2.png"),
}
var player_level: Dictionary[int, CompressedTexture2D] = {
	1: preload("res://Assets/LevelDownMenu/Level_Numbers/Level1.png"),
	0: preload("res://Assets/LevelDownMenu/Level_Numbers/Level0.png"),
	-1: preload("res://Assets/LevelDownMenu/Level_Numbers/Level-1.png"),
	-2: preload("res://Assets/LevelDownMenu/Level_Numbers/Level-2.png"),
	-3: preload("res://Assets/LevelDownMenu/Level_Numbers/Level-3.png")
}


signal armor_updated(amount: int)
	
@onready var resource: CharacterStatsResource = CharacterStatsResource.new()
var current_armor: int = 2

func reset_current_armor() -> void:
	current_armor = PlayerStats.resource.armor
	armor_updated.emit(current_armor)
