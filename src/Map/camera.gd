extends Camera3D

@export var margin = .2
@export var pan_speed = 1
@export var rail_speed = 0
@export var amplitude_vt = 0  # degrees
@export var amplitude_hz = 120  # degrees
@export var center = Vector2(-20, 0)

@onready var rail = $".."
@onready var hand = $"../../../2DHand"
@onready var finger_tip = $"../../../2DHand/HandBody/Sprite2D/FingerTip"
@onready var billboard = $"../../../Billboard"
@onready var sleeve_anchor: Node3D = %SleeveAnchor
@onready var sleeve_hand: Sprite3D = %SleeveHand


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
		global_rotation += pan_speed * delta * Vector3(y_coeff, x_coeff, 0)
		global_rotation = global_rotation.clamp(
			Vector3(deg_to_rad(center.x - amplitude_vt), deg_to_rad(center.y - amplitude_hz), 0),
			Vector3(deg_to_rad(center.x + amplitude_vt), deg_to_rad(center.y + amplitude_hz), 0)
		)
		if global_rotation.x > deg_to_rad(center.x + amplitude_vt - 1):
			rail.progress_ratio = .011
			global_rotation.x = deg_to_rad(center.x + amplitude_vt - 1)
	else:
		global_rotation += pan_speed * delta * Vector3(0, x_coeff, 0)
		global_rotation = global_rotation.clamp(
			Vector3(global_rotation.x, deg_to_rad(center.y - amplitude_hz), 0),
			Vector3(global_rotation.x, deg_to_rad(center.y + amplitude_hz), 0)
		)
		if rail.progress_ratio < .6:
			y_coeff = clamp(y_coeff, -1.0, 1.0)
		else:
			y_coeff = clamp(y_coeff, -1.0, 0)
		rail.progress_ratio += rail_speed * delta * y_coeff
		global_rotation.x = lerp(
			deg_to_rad(center.x + amplitude_vt - 1),
			deg_to_rad(center.x - 2 * amplitude_vt),
			rail.progress_ratio
		)
		if rail.progress_ratio < 0.011:
			rail.progress_ratio = 0.01
			global_rotation.x = deg_to_rad(center.x + amplitude_vt - 1)
		if rail.progress_ratio > .6:
			rail.progress_ratio = .6

	# horizontal movement
	# billboard.position.x = 600 + global_rotation.y * 600
	# # vertical movement
	# billboard.position.y = (-0.4 - global_rotation.x) * 1000  #+ (1 - cos(global_rotation.y)) * 200
	billboard.visible = not is_position_behind(sleeve_anchor.global_transform.origin)
	billboard.position = unproject_position(sleeve_anchor.global_transform.origin)
	# billboard.global_position = unproject_position(sleeve_anchor.global_position) / 100
	# print(billboard.position)

	# sleeve_hand.look_at(global_position)
	sleeve_hand.global_rotation = global_rotation
