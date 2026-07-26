extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	PlayerStats.current_armor -= 1
	PlayerStats.armor_updated.emit(PlayerStats.current_armor)
	self.queue_free()
