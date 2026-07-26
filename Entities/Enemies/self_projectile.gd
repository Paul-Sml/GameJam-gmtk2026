extends Node2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var distance_max: float = 0.0
var traveled: float = 0.0
var is_launched: bool = false


func launch(dash_direction: Vector2, max_distance: float, dash_speed: float) -> void:
	direction = dash_direction
	speed = dash_speed
	distance_max = max_distance
	is_launched = true


func _physics_process(delta: float) -> void:
	if not is_launched:
		return

	var move_amount: float = speed * delta
	var remaining: float = distance_max - traveled
	move_amount = min(move_amount, remaining)

	global_position += direction * move_amount
	traveled += move_amount

	if traveled >= distance_max:
		queue_free()
