extends Area2D
class_name Hurtbox

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
		
	if owner.has_method("receive_attack"):
		owner.receive_attack(hitbox)
