extends Node2D

const SPAWN_INDICATOR = preload("uid://bktduw1t6kivc")
@onready var wave2: Node2D = $Wave2
var wave3: Node2D

@onready var enemy_nodes: Array[Node] = wave2.get_children()
var enemy_positions: Array[Vector2] = []
var enemy_nodes3: Array[Node]
var enemy_positions3: Array[Vector2] = []

func _ready() -> void:
	for enemy in enemy_nodes:
		enemy.visible = false
		enemy_positions.append(enemy.global_position)
	if $Wave3 != null:
		wave3 = $Wave3
		enemy_nodes3 = wave3.get_children()
		for enemy in enemy_nodes3:
			enemy.visible = false
			enemy_positions3.append(enemy.global_position)

func start_wave_2() -> void:
	print(enemy_positions)
	var indicators: Array[Node2D] = []
	var tweens: Array[Tween] = []
	
	for pos in enemy_positions:
		var indicator := SPAWN_INDICATOR.instantiate()
		wave2.add_child(indicator)
		indicator.global_position = pos
		indicators.append(indicator)
		
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(indicator, "modulate:a", 0.3, 0.5)
		tween.tween_property(indicator, "modulate:a", 1.0, 0.5)
		tweens.append(tween)
	
	await get_tree().create_timer(2.5).timeout
	
	for tween in tweens:
		tween.kill()  # arrête le Tween proprement avant de détruire le node
	
	for indicator in indicators:
		indicator.queue_free()
	
	for enemy in enemy_nodes:
		enemy.visible = true
		wave2.process_mode = Node.PROCESS_MODE_INHERIT

func start_wave_3() -> void:
	print(enemy_positions)
	var indicators: Array[Node2D] = []
	var tweens: Array[Tween] = []
	
	for pos in enemy_positions:
		var indicator := SPAWN_INDICATOR.instantiate()
		wave3.add_child(indicator)
		indicator.global_position = pos
		indicators.append(indicator)
		
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(indicator, "modulate:a", 0.3, 0.5)
		tween.tween_property(indicator, "modulate:a", 1.0, 0.5)
		tweens.append(tween)
	
	await get_tree().create_timer(2.5).timeout
	
	for tween in tweens:
		tween.kill()  # arrête le Tween proprement avant de détruire le node
	
	for indicator in indicators:
		indicator.queue_free()
	
	for enemy in enemy_nodes:
		enemy.visible = true
		wave3.process_mode = Node.PROCESS_MODE_INHERIT
