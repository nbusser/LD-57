@tool
extends Node3D

@onready var label_3d: Label3D = $Label3D

@export_range(0, 20) var value = 20:
	set(new_value):
		value = new_value
		_on_value_update()


func _ready():
	_on_value_update()


func _on_value_update():
	label_3d.text = str(value)
