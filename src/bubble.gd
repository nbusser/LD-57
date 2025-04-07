class_name Dialog extends StaticBody3D

signal clicked

@onready var label = get_node("Label3D")
# @onready var area = get_node("Area3D")
@onready var col_shape = get_node("collision")


func _ready():
	# show_messages(["Hello", "World"])
	Globals.set_dialog(self)


func show_messages(messages: Array[String], can_click = true):
	for message in messages:
		label.text = message
		if can_click:
			await clicked
	if can_click:
		label.text = ""


func wait_for_click():
	await clicked
	label.text = ""


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
