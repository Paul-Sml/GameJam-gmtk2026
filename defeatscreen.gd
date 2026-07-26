extends Node2D

func _on_reset_pressed() -> void:
	PlayerStats.reset_stats()
	get_tree().change_scene_to_packed(load(PlayerStats.MAIN_MENU))
