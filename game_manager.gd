extends Node2D

var level_id: int = 0
var levels: Array[String] = [
	"res://Maps/level1.tscn",
	"res://Maps/level0.tscn",
	"res://Maps/level-1.tscn"
]
var timers: Array[int] = [
	5,
	5,
	5
]

@onready var armor_label: Label = %ArmorLabel
@onready var strength_label: Label = %StrengthLabel
@onready var speed_label: Label = %SpeedLabel

@onready var current_level: Node2D = %CurrentLevel
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var level_down_menu: LevelDownMenu = %LevelDownMenu
@onready var timer: GameTimer = %Timer
@onready var survive: Sprite2D = %Survive

@onready var armor_icons: HBoxContainer = %ArmorIcons

func _ready() -> void:
	PlayerStats.armor_updated.connect(_on_player_armor_updated)
	new_stage()

func new_stage() -> void:
	print("new level !")
	load_stage(level_id)
	
	armor_label.text = str(PlayerStats.resource.armor)
	strength_label.text = str(PlayerStats.resource.strength)
	speed_label.text = str(PlayerStats.resource.speed)
	
	survive.visible = true
	await wait_for_input()
	survive.visible = false
	
	PlayerStats.reset_current_armor()
	current_level.visible = true
	current_level.process_mode = Node2D.PROCESS_MODE_INHERIT
	canvas_layer.visible = true
	timer.start_timer(timers[level_id])
	level_id += 1

func wait_for_input() -> void:
	while true:
		await get_tree().process_frame
		if (
			Input.is_action_just_pressed("left") or \
			Input.is_action_just_pressed("right") or \
			Input.is_action_just_pressed("up") or \
			Input.is_action_just_pressed("down") or \
			Input.is_action_just_pressed("LMB")
			):
			break

func load_stage(index: int) -> void:
	print("loading level ", index)
	
	var level_scene: PackedScene = load(levels[index])
	var level_instance: Node = level_scene.instantiate()
	
	current_level.add_child(level_instance)

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
