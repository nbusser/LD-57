extends Node3D

@export_range(0, 20) var value = 20:
	set(new_value):
		value = new_value
		_on_value_update()

@onready var label_3d: Label3D = $Label3D
@onready var points: Node3D = $Points


func _ready():
	var children = points.get_children()
	for i in range(children.size()):
		var point = children[i]
		# point.position = Vector3(i * 0.04, 0, 0)
		point.color = Color.BLACK
	_on_value_update()


func _on_value_update():
	label_3d.text = str(value)
	var children = points.get_children()
	for i in range(children.size()):
		var point = children[i]
		if i < value:
			point.color = Color.WHITE
		else:
			point.color = Color.BLACK
