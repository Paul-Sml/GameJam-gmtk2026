extends Node2D

@onready var current_level: Node2D = %CurrentLevel
@onready var armor_icons: HBoxContainer = %ArmorIcons

func _ready() -> void:
	new_level()

func new_level() -> void:
	#load level
	var player: Player = find_player_in_current_level()
	if player == null:
		push_error("No player found in current level")
		return
	else:
		player.armor_updated.connect(_on_player_armor_updated)
		print("Player found in current level: ", player.name)

func find_player_in_current_level() -> Player:
	for player in get_tree().get_nodes_in_group("player"):
		if current_level.is_ancestor_of(player) and player is Player:
			return player
	return null

func _on_player_armor_updated(amount: int) -> void:
	print("Player armor updated: ", amount)
	armor_icons.get_child(0).visible = amount >= 1
	armor_icons.get_child(1).visible = amount >= 2
