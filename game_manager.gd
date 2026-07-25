extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var level_id: int = 0
var level_number: Array[int] = [
	1,
	0,
	-1
]
var levels: Array[String] = [
	"res://Maps/level1.tscn",
	"res://Maps/level0.tscn",
	"res://Maps/level-1.tscn"
]
var timers: Array[int] = [
	1,
	2,
	30
]

@onready var armor_amt: TextureRect = %ArmorAmt
@onready var strength_amt: TextureRect = %StrengthAmt
@onready var speed_amt: TextureRect = %SpeedAmt

@onready var current_level: Node2D = %CurrentLevel
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var level_down_menu: LevelDownMenu = %LevelDownMenu
@onready var timer: GameTimer = %Timer
@onready var survive: Sprite2D = %Survive

@onready var armor_icons: HBoxContainer = %ArmorIcons
@onready var stage_no: Label = %StageNo
@onready var stage_cleared: Label = %StageCleared

func _ready() -> void:
	PlayerStats.armor_updated.connect(_on_player_armor_updated)
	new_stage()

func new_stage() -> void:
	print("new level !")
	load_stage(level_id)
	%Exposed.visible = false
	
	stage_no.text = stage_no.text.substr(0, stage_no.text.length() - 1) + str(level_number[level_id])
	armor_amt.texture = PlayerStats.stats_points.get(PlayerStats.resource.armor)
	strength_amt.texture = PlayerStats.stats_points.get(PlayerStats.resource.strength)
	speed_amt.texture = PlayerStats.stats_points.get(PlayerStats.resource.speed)
	timer.set_timer(timers[level_id])
	current_level.visible = true
	survive.visible = true
	await wait_for_input()
	survive.visible = false
	
	PlayerStats.reset_current_armor()
	
	current_level.process_mode = Node2D.PROCESS_MODE_INHERIT
	canvas_layer.visible = true
	timer.start_timer()
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

const SHIELD_ICON = preload("uid://doixyltdr5vk2")
const SHIELD_ICON_NEGATIVE = preload("uid://bd8avl68bwfl1")

func _on_player_armor_updated(amount: int) -> void:
	var icon: Texture2D = SHIELD_ICON_NEGATIVE if amount < 0 else SHIELD_ICON

	for i in armor_icons.get_child_count():
		var icon_node: TextureRect = armor_icons.get_child(i)
		icon_node.texture = icon
		icon_node.visible = abs(amount) >= i + 1
	if amount == 0:
		%Exposed.visible = true

func _on_timer_timer_reached_zero() -> void:
	await get_tree().process_frame
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	animation_player.play("cleared")
	await animation_player.animation_finished
	for child in current_level.get_children():
		child.queue_free()
	current_level.visible = false
	stage_cleared.position = Vector2(237,-266)
	current_level.process_mode = Node2D.PROCESS_MODE_DISABLED
	canvas_layer.visible = false
	level_down_menu.level_down()


func _on_next_level() -> void:
	new_stage()


func _on_level_down_menu_next_level() -> void:
	pass # Replace with function body.
