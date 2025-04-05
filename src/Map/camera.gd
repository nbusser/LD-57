extends Camera3D

func _physics_process(delta: float) -> void:
	const margin_prop = .1
	const speed = .008
	const amplitude = 20 # degrees
	
	var x_ratio = get_viewport().get_mouse_position().x/get_viewport().get_size().x
	var y_ratio = get_viewport().get_mouse_position().y/get_viewport().get_size().y
	if x_ratio < margin_prop:
		rotation += Vector3(0, speed, 0)
	elif x_ratio > (1.0 - margin_prop):
		rotation -= Vector3(0, speed, 0)
	if y_ratio < margin_prop:
		rotation += Vector3(speed, 0, 0)
	elif y_ratio > (1.0 - margin_prop):
		rotation -= Vector3(speed, 0, 0)
	rotation = rotation.clamp(
		Vector3(deg_to_rad(-20 - amplitude), deg_to_rad(-amplitude), 0),
		Vector3(deg_to_rad(-20 + amplitude), deg_to_rad(amplitude), 0)
	)
