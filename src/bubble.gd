class_name Dialog extends StaticBody3D

signal clicked

@onready var label = get_node("Label3D")
# @onready var area = get_node("Area3D")
@onready var col_shape = get_node("collision")

func _ready():
	show_message(["Hello", "World"])


func show_message(messages: Array[String]):
	# label.text = message
	print("setting...")
	for message in messages:
		label.text = message
		# col_shape.shape.size = Vector3(label.text.length() * 0.1, 0.1, 0.1)
		print("waiting...")
		await clicked
		print("done")


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		var space_state = get_world_3d().direct_space_state
		# var params = PhysicsRayQueryParameters3D.create(from, to, 1<<4)
		var params = PhysicsRayQueryParameters3D.create(from, to)
		params.collide_with_bodies = true
		var result = space_state.intersect_ray(params)

		if result and result.collider == self:
			clicked.emit()
