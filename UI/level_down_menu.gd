extends Control
class_name LevelDownMenu

signal next_level

@export var player_resource: CharacterStatsResource
var saved_player_resource: CharacterStatsResource
@onready var level_down_transi: TextureButton = %LevelDownTransi
@onready var armor_button: TextureButton = $Menuing/VBoxContainer2/Armor/TickableCounter/ArmorButton
@onready var strength_button: TextureButton = $Menuing/VBoxContainer2/Strength/TickableCounter/StrengthButton
@onready var speed_button: TextureButton = $Menuing/VBoxContainer2/Speed/TickableCounter/SpeedButton

#func _ready() -> void:
	#var resource = CharacterStatsResource.new()
	#resource.level_down()
	#open_menu(resource)
	
func level_down() -> void:
	print("level down")
	player_resource.level_down()
	level_down_transi.visible = true
	#level_down_transi.disabled = false
	saved_player_resource = player_resource.duplicate(true)
	update_visuals()
	visible = true

func _on_level_down_transi_pressed() -> void:
	level_down_transi.visible = false
	#level_down_transi.disabled = true

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
	if player_resource.points_remaining == 0:
		visible_buttons(false)
	else:
		visible_buttons(true)

func _on_armor_button_pressed() -> void:
	if player_resource.points_remaining < 0:
		player_resource.armor -= 1
		armor_label.text = str(player_resource.armor)
		player_resource.points_remaining += 1
		points_label.text = str(player_resource.points_remaining)
		if player_resource.points_remaining == 0:
			visible_buttons(false)

func _on_strength_button_pressed() -> void:
	if player_resource.points_remaining < 0:
		player_resource.strength -= 1
		strength_label.text = str(player_resource.strength)
		player_resource.points_remaining += 1
		points_label.text = str(player_resource.points_remaining)
		if player_resource.points_remaining == 0:
			visible_buttons(false)

func _on_speed_button_pressed() -> void:
	if player_resource.points_remaining < 0:
		player_resource.speed -= 1
		speed_label.text = str(player_resource.speed)
		player_resource.points_remaining += 1
		points_label.text = str(player_resource.points_remaining)
		if player_resource.points_remaining == 0:
			visible_buttons(false)

func visible_buttons(visible: bool) -> void:
	armor_button.modulate = Color(1, 1, 1, 1 if visible else 0)
	strength_button.modulate = Color(1, 1, 1, 1 if visible else 0)
	speed_button.modulate = Color(1, 1, 1, 1 if visible else 0)

func _on_reset_pressed() -> void:
	player_resource = saved_player_resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	update_visuals()

func _on_validate_pressed() -> void:
	if player_resource.points_remaining > 0:
		return
	#next_level.emit()
	#current_level.visible = true
	#close_menu()
