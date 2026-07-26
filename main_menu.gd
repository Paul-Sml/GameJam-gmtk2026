extends Node2D

func _on_validate_pressed() -> void:
	get_tree().change_scene_to_packed(load(PlayerStats.GAME_SCENE))
