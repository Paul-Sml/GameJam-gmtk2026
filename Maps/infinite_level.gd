extends Level
const SPAWN_INDICATOR = preload("uid://bktduw1t6kivc")
const ENEMY = preload("uid://npnutmg8mqpu")
const TURRET = preload("uid://b2385ms0csvlt")

@export var number_of_enemies: int = 3

var enemy_positions: Array[Vector2] = []


func new_wave() -> void:
	number_of_enemies += 1
	enemy_positions = find_spawn_positions(number_of_enemies)

	var indicators: Array[Node2D] = []
	var tweens: Array[Tween] = []

	for pos in enemy_positions:
		var indicator := SPAWN_INDICATOR.instantiate()
		add_child(indicator)
		indicator.global_position = pos
		indicators.append(indicator)

		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(indicator, "modulate:a", 0.3, 0.5)
		tween.tween_property(indicator, "modulate:a", 1.0, 0.5)
		tweens.append(tween)

	await get_tree().create_timer(2.5).timeout

	for tween in tweens:
		tween.kill()

	for indicator in indicators:
		indicator.queue_free()

	for i in enemy_positions.size():
		var scene: PackedScene = TURRET if i == 0 else ENEMY
		var enemy := scene.instantiate()
		add_child(enemy)
		enemy.global_position = enemy_positions[i]


func find_spawn_positions(count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var nav_map: RID = nav_region.get_navigation_map()
	var max_attempts_per_spawn: int = 50

	for i in range(count):
		var found: bool = false
		var attempts: int = 0

		while not found and attempts < max_attempts_per_spawn:
			attempts += 1
			var raw_point: Vector2 = NavigationServer2D.map_get_random_point(nav_map, 1, false)
			var candidate: Vector2 = (raw_point / tile_size).round() * tile_size

			if is_position_valid(candidate, positions):
				positions.append(candidate)
				found = true

	return positions


func is_position_valid(pos: Vector2, existing_positions: Array[Vector2]) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(spawn_size, spawn_size)
	query.shape = shape
	query.transform = Transform2D(0, pos)

	var results: Array = space_state.intersect_shape(query, 1)
	if results.size() > 0:
		return false

	for existing in existing_positions:
		if pos.distance_to(existing) < spawn_size * 2:
			return false

	return true
