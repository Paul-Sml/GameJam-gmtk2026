extends Control
class_name GameTimer

@onready var timer: Timer = %Timer
@onready var label: Label = %Label

signal timer_reached_zero

var remaining_time: int:
	set(value):
		remaining_time = value
		if remaining_time == 0:
			timer.stop()
			timer_reached_zero.emit()

func set_timer(time:int) -> void:
	remaining_time = time
	updateValue()

func start_timer() -> void:
	timer.start()

func updateValue() -> void:
	label.text = str(remaining_time)

func _on_timer_timeout() -> void:
	remaining_time -= 1
	updateValue()
