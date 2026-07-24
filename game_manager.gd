extends Node2D

var level_id: int = 0
var levels: Array[String] = [
	"res://Maps/level1.tscn",
	"res://Maps/level0.tscn",
	"res://Maps/level-1.tscn"
]
var timers: Array[int] = [
	2,
	2,
	2
]


@onready var current_level: Node2D = %CurrentLevel
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var level_down_menu: LevelDownMenu = %LevelDownMenu
@onready var timer: GameTimer = %Timer

@onready var armor_icons: HBoxContainer = %ArmorIcons

func _ready() -> void:
	new_stage()

func new_stage() -> void:
	print("new level !")
	load_stage(level_id)
	level_id += 1
	var player: Player = find_player_in_current_level()
	if player == null:
		push_error("No player found in current level")
		return
	player.armor_updated.connect(_on_player_armor_updated)
	current_level.visible = true
	current_level.process_mode = Node2D.PROCESS_MODE_INHERIT
	canvas_layer.visible = true


func load_stage(index: int) -> void:
	print("loading level ", index)
	
	var level_scene: PackedScene = load(levels[index])
	var level_instance: Node = level_scene.instantiate()
	
	current_level.add_child(level_instance)
	timer.start_timer(timers[index])

func find_player_in_current_level() -> Player:
	for player in get_tree().get_nodes_in_group("player"):
		if current_level.is_ancestor_of(player) and player is Player:
			return player
	return null

func _on_player_armor_updated(amount: int) -> void:
	print("Player armor updated: ", amount)
	armor_icons.get_child(0).visible = amount >= 1
	armor_icons.get_child(1).visible = amount >= 2


func _on_timer_timer_reached_zero() -> void:
	for child in current_level.get_children():
		child.queue_free()
	current_level.visible = false
	current_level.process_mode = Node2D.PROCESS_MODE_DISABLED
	canvas_layer.visible = false
	level_down_menu.level_down()


func _on_next_level() -> void:
	new_stage()


func _on_level_down_menu_next_level() -> void:
	pass # Replace with function body.
