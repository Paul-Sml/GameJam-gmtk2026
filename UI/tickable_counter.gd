extends VBoxContainer

@onready var label: Label = $ColorRect/Label

@export var value:int = 5

func _ready() -> void:
	updateValue()

func _on_button_2_pressed() -> void:
	value -= 1
	updateValue()

func updateValue() -> void:
	label.text = str(value)
