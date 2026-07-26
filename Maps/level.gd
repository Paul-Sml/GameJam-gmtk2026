extends Node2D
class_name Level

@onready var nav_region: NavigationRegion2D = %NavigationRegion2D
var tile_size: int = 64
var spawn_size: float = 128.0
const SHIELD = preload("uid://2a6amucujj8a")

func spawn_neg_shield() -> void:
	var shield := SHIELD.instantiate()
	add_child(shield)
	shield.global_position = find_spawn_positions(1)[0]

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
