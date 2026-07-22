extends CharacterBody2D

@export var speed: float = 300.0

func _ready() -> void:
	print("Window size: ", get_window().size)
	print("Viewport size: ", get_viewport().size)

func _on_resized() -> void:
	print("Resized! New size: ", get_window().size)
	
func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	
	move_and_slide()
