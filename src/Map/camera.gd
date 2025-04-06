extends Camera3D

@export var margin = .2
@export var pan_speed = 1
@export var rail_speed = 1
@export var amplitude_vt = 10  # degrees
@export var amplitude_hz = 3  # degrees
@export var center = Vector2(-30, 0)

@onready var rail = $".."
@onready var hand = $"../../../2DHand"
@onready var finger_tip = $"../../../2DHand/HandBody/Sprite2D/FingerTip"


func _physics_process(delta: float) -> void:
	var x_ratio = finger_tip.global_position.x / get_viewport().get_size().x
	var y_ratio = finger_tip.global_position.y / get_viewport().get_size().y

	var x_coeff = 0.0
	var y_coeff = 0.0
	if x_ratio < margin:
		x_coeff = pow(1.0 - x_ratio / margin, 4.0)
	elif x_ratio > (1.0 - margin):
		x_coeff = -pow(1.0 - (1.0 - x_ratio) / margin, 4.0)
	if y_ratio < margin:
		y_coeff = pow(1.0 - y_ratio / margin, 2.0)
	elif y_ratio > (1.0 - margin):
		y_coeff = -pow(1.0 - (1.0 - y_ratio) / margin, 2.0)
	x_coeff = clamp(x_coeff, -1.0, 1.0)
	y_coeff = clamp(y_coeff, -1.0, 1.0)

	if rail.progress_ratio == .01:
		rotation += pan_speed * delta * Vector3(y_coeff, x_coeff, 0)
		rotation = rotation.clamp(
			Vector3(deg_to_rad(center.x - amplitude_vt), deg_to_rad(center.y - amplitude_hz), 0),
			Vector3(deg_to_rad(center.x + amplitude_vt), deg_to_rad(center.y + amplitude_hz), 0)
		)
		if rotation.x > deg_to_rad(center.x + amplitude_vt - 1):
			rail.progress_ratio = .011
			rotation.x = deg_to_rad(center.x + amplitude_vt - 1)
	else:
		rotation += pan_speed * delta * Vector3(0, x_coeff, 0)
		rotation = rotation.clamp(
			Vector3(rotation.x, deg_to_rad(center.y - amplitude_hz), 0),
			Vector3(rotation.x, deg_to_rad(center.y + amplitude_hz), 0)
		)
		if rail.progress_ratio < .6:
			y_coeff = clamp(y_coeff, -1.0, 1.0)
		else:
			y_coeff = clamp(y_coeff, -1.0, 0)
		rail.progress_ratio += rail_speed * delta * y_coeff
		rotation.x = lerp(
			deg_to_rad(center.x + amplitude_vt - 1),
			deg_to_rad(center.x - 2 * amplitude_vt),
			rail.progress_ratio
		)
		if rail.progress_ratio < 0.011:
			rail.progress_ratio = 0.01
			rotation.x = deg_to_rad(center.x + amplitude_vt - 1)
		if rail.progress_ratio > .6:
			rail.progress_ratio = .6
