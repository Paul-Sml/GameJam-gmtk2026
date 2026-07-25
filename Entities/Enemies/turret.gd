extends Enemy

const PROJECTILE = preload("uid://d0d4odmovs8pb")

func _physics_process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	spawn_projectile()

func spawn_projectile() -> void:
	var projectile: Node2D = PROJECTILE.instantiate()
	
	var direction: Vector2 = global_position.direction_to(player.global_position)
	projectile.rotation = direction.angle()
	
	get_parent().add_child(projectile)
	projectile.global_position = global_position
