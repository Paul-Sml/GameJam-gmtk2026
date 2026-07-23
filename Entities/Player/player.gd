extends CharacterBody2D

@export var speed: float = 300.0
@onready var hit_box: Area2D = $Attacks/HitBox

func _ready() -> void:
	print("Window size: ", get_window().size)
	print("Viewport size: ", get_viewport().size)

func _on_resized() -> void:
	print("Resized! New size: ", get_window().size)
	
func _physics_process(delta: float) -> void:
	movement()
	attacking()

func movement() -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()

func attacking() -> void:
	if Input.is_action_just_pressed("LMB"):
		print("attack")
		hit_box.look_at(get_global_mouse_position())
		hit_box.visible = true
		hit_box.monitorable = true
		await get_tree().create_timer(0.5).timeout #TODO : Real timer
		hit_box.visible = false
		hit_box.monitorable = false


func _on_hit_box_area_entered(area: Area2D) -> void:
	print(area)
	pass # Replace with function body.


func _on_hit_box_body_entered(body: Node2D) -> void:
	print(body)
	pass # Replace with function body.
