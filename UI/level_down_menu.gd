extends Control
class_name LevelDownMenu

signal next_level()

var saved_player_resource: CharacterStatsResource
@onready var level_down_transi: Button = %LevelDownTransi
@onready var remaining_points_texture: TextureRect = %pta
@onready var strength_button: TextureButton = %StrengthButton
@onready var armor_button: TextureButton = %ArmorButton
@onready var speed_button: TextureButton = %SpeedButton
const BUTTON_NEG = preload("uid://da0y7rnb7y1x0")
const BUTTON_NEG_PRESSED = preload("uid://ccy1ibmjqgyhg")
const BUTTON_POS = preload("uid://cdn3hop83k8h4")
const BUTTON_POS_PRESSED = preload("uid://biv2iyx4ebhnh")

func set_buttons_textures() -> void:
	set_button_textures(armor_button, PlayerStats.resource.armor)
	set_button_textures(strength_button, PlayerStats.resource.strength)
	set_button_textures(speed_button, PlayerStats.resource.speed)

func set_button_textures(button: TextureButton, amount: int) -> void:
	if amount > 0:
		button.texture_normal = BUTTON_POS
		button.texture_pressed = BUTTON_POS_PRESSED
	else:
		button.texture_normal = BUTTON_NEG
		button.texture_pressed = BUTTON_NEG_PRESSED
	if amount == -2:
		button.disabled = true
		button.modulate = Color(1, 1, 1, 0)
	else:
		button.disabled = false
		button.modulate = Color(1, 1, 1, 1)

var can_skip: bool = false

#func _ready() -> void:
	#var resource = CharacterStatsResource.new()
	#resource.level_down()
	#open_menu(resource)
	
func level_down() -> void:
	print("level down")
	PlayerStats.resource.level_down()
	level_down_transi.visible = true
	get_tree().create_timer(1.0).timeout.connect(func(): can_skip = true)
	#level_down_transi.disabled = false
	saved_player_resource = PlayerStats.resource.duplicate(true)
	update_visuals()
	visible = true

func _on_level_down_transi_pressed() -> void:
	if can_skip:
		level_down_transi.visible = false
	#level_down_transi.disabled = true

func close_menu() -> void:
	visible = false
	
@onready var armor_amount: TextureRect = %ArmorAmount
@onready var strength_amount: TextureRect = %StrengthAmount
@onready var speed_amount: TextureRect = %SpeedAmount
@onready var level_label: Label = %Level

func update_visuals() -> void:
	level_label.text = level_label.text.substr(0, level_label.text.length() - 1) + str(PlayerStats.resource.level)
	remaining_points_texture.texture = PlayerStats.stats_points.get(PlayerStats.resource.points_remaining)
	armor_amount.texture = PlayerStats.stats_points.get(PlayerStats.resource.armor)
	strength_amount.texture = PlayerStats.stats_points.get(PlayerStats.resource.strength)
	speed_amount.texture = PlayerStats.stats_points.get(PlayerStats.resource.speed)
	if PlayerStats.resource.points_remaining == 0:
		visible_buttons(false)
	else:
		visible_buttons(true)
		set_buttons_textures()

func _on_armor_button_pressed() -> void:
	if PlayerStats.resource.points_remaining < 0:
		PlayerStats.resource.armor -= 1
		armor_amount.texture = PlayerStats.stats_points.get(PlayerStats.resource.armor)
		PlayerStats.resource.points_remaining += 1
		remaining_points_texture.texture = PlayerStats.stats_points.get(PlayerStats.resource.points_remaining)
		if PlayerStats.resource.points_remaining == 0:
			visible_buttons(false)
		else:
			set_buttons_textures()

func _on_strength_button_pressed() -> void:
	if PlayerStats.resource.points_remaining < 0:
		PlayerStats.resource.strength -= 1
		strength_amount.texture = PlayerStats.stats_points.get(PlayerStats.resource.strength)
		PlayerStats.resource.points_remaining += 1
		remaining_points_texture.texture = PlayerStats.stats_points.get(PlayerStats.resource.points_remaining)
		if PlayerStats.resource.points_remaining == 0:
			visible_buttons(false)
		else:
			set_buttons_textures()

func _on_speed_button_pressed() -> void:
	if PlayerStats.resource.points_remaining < 0:
		PlayerStats.resource.speed -= 1
		speed_amount.texture = PlayerStats.stats_points.get(PlayerStats.resource.speed)
		PlayerStats.resource.points_remaining += 1
		remaining_points_texture.texture = PlayerStats.stats_points.get(PlayerStats.resource.points_remaining)
		if PlayerStats.resource.points_remaining == 0:
			visible_buttons(false)
		else:
			set_buttons_textures()

func visible_buttons(_is_visible: bool) -> void:
	armor_button.modulate = Color(1, 1, 1, 1 if _is_visible else 0)
	strength_button.modulate = Color(1, 1, 1, 1 if _is_visible else 0)
	speed_button.modulate = Color(1, 1, 1, 1 if _is_visible else 0)

func _on_reset_pressed() -> void:
	PlayerStats.resource = saved_player_resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	update_visuals()

func _on_validate_pressed() -> void:
	if PlayerStats.resource.points_remaining < 0:
		remaining_points_texture.modulate = Color(1, 0.2, 0.2, 1)
		await get_tree().create_timer(1).timeout
		remaining_points_texture.modulate = Color(1, 1, 1, 1)
		return
	next_level.emit()
	#current_level.visible = true
	can_skip = false
	close_menu()
