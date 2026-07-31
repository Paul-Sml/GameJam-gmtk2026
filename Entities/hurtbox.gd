extends Area2D
class_name Hurtbox

var neg_hit_cooldown: bool = false
const NEG_HIT_COOLDOWN_DURATION: float = 0.2

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return

	if hitbox.isNeg:
		if neg_hit_cooldown:
			return
		neg_hit_cooldown = true
		start_neg_hit_cooldown()

	if owner.has_method("receive_attack"):
		owner.receive_attack(hitbox)

func start_neg_hit_cooldown() -> void:
	await get_tree().create_timer(NEG_HIT_COOLDOWN_DURATION).timeout
	neg_hit_cooldown = false
