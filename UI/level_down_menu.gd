extends Control
class_name LevelDownMenu

signal next_level

@export var player_resource: CharacterStatsResource
var saved_player_resource: CharacterStatsResource

#func _ready() -> void:
	#var resource = CharacterStatsResource.new()
	#resource.level_down()
	#open_menu(resource)

func open_menu() -> void:
	saved_player_resource = player_resource.duplicate(true)
	update_visuals()
	visible = true

func close_menu() -> void:
	visible = false

@onready var level_label: Label = %LevelLabel
@onready var points_label: Label = %PointsLabel
@onready var armor_label: Label = %ArmorLabel
@onready var strength_label: Label = %StrengthLabel
@onready var speed_label: Label = %SpeedLabel

func update_visuals() -> void:
	level_label.text = str(player_resource.level)
	points_label.text = str(player_resource.points_remaining)
	armor_label.text = str(player_resource.armor)
	strength_label.text = str(player_resource.strength)
	speed_label.text = str(player_resource.speed)

func _on_armor_button_pressed() -> void:
	if player_resource.points_remaining < 0:
		player_resource.armor -= 1
		armor_label.text = str(player_resource.armor)
		player_resource.points_remaining += 1
		points_label.text = str(player_resource.points_remaining)

func _on_strength_button_pressed() -> void:
	if player_resource.points_remaining < 0:
		player_resource.strength -= 1
		strength_label.text = str(player_resource.strength)
		player_resource.points_remaining += 1
		points_label.text = str(player_resource.points_remaining)

func _on_speed_button_pressed() -> void:
	if player_resource.points_remaining < 0:
		player_resource.speed -= 1
		speed_label.text = str(player_resource.speed)
		player_resource.points_remaining += 1
		points_label.text = str(player_resource.points_remaining)

func _on_reset_pressed() -> void:
	player_resource = saved_player_resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	update_visuals()

func _on_validate_pressed() -> void:
	next_level.emit()
	%Level.visible = true
	close_menu()

func _on_timer_reached_zero() -> void:
	player_resource.level_down()
	%Level.visible = false
	open_menu()
