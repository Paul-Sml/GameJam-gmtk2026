extends Control

@onready var timer: Timer = $Timer
@onready var label: Label = $Label

signal timer_reached_zero

@export var max_time:int = 15
var remaining_time: int:
	set(value):
		remaining_time = value
		if remaining_time == 0:
			_self_timer_finished()

func _self_timer_finished() -> void:
	print("GG")
	timer_reached_zero.emit()

func _on_timer_timeout() -> void:
	remaining_time -= 1
	updateValue()

func _ready() -> void:
	remaining_time = max_time
	updateValue()

func updateValue() -> void:
	label.text = str(remaining_time)
