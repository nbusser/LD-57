extends Camera3D

@onready var Rail = get_node("..")
@onready var HandTopView = get_node("../../../Hand")
@onready var HandFrontView = get_node("../../../2DHand")

@export var margin_hand = .2
@export var speed_hand = 1
@export var amplitude_hand_vt = 10 # degrees
@export var amplitude_hand_hz = 3 # degrees
@export var center_hand = Vector2(-30, 0)

@export var margin_table = .4
@export var speed_table = .6
@export var amplitude_table = 3 # degrees
@export var center_table = Vector2(-90, 0)

enum ViewMode {HAND_MODE, TABLE_MODE, IN_TRANSITION}
var current_mode: ViewMode = ViewMode.HAND_MODE

func _physics_process(delta: float) -> void:
	var x_ratio = get_viewport().get_mouse_position().x/get_viewport().get_size().x
	var y_ratio = get_viewport().get_mouse_position().y/get_viewport().get_size().y
	
	if current_mode == ViewMode.HAND_MODE: # horizontal panning only
		var x_coeff = 0.0
		var y_coeff = 0.0
		if x_ratio < margin_hand:
			x_coeff = pow(1.0 - x_ratio/margin_hand, 4.0)
		elif x_ratio > (1.0 - margin_hand):
			x_coeff = -pow(1.0 - (1.0 - x_ratio)/margin_hand, 4.0)
		if y_ratio < margin_hand:
			y_coeff = pow(1.0 - y_ratio/margin_hand, 2.0)
		elif y_ratio > (1.0 - margin_hand):
			y_coeff = -pow(1.0 - (1.0 - y_ratio)/margin_hand, 2.0)
		x_coeff = clamp(x_coeff, -1.0, 1.0)
		y_coeff = clamp(y_coeff, -1.0, 1.0)
		rotation += speed_hand*delta*Vector3(y_coeff, x_coeff, 0)
		rotation = rotation.clamp(
			Vector3(deg_to_rad(center_hand.x - amplitude_hand_vt), deg_to_rad(center_hand.y - amplitude_hand_hz), 0),
			Vector3(deg_to_rad(center_hand.x + amplitude_hand_vt), deg_to_rad(center_hand.y + amplitude_hand_hz), 0)
		)
		if rotation.x > deg_to_rad(center_hand.x + amplitude_hand_vt - 1):
			switch_mode(ViewMode.TABLE_MODE)
	elif current_mode == ViewMode.TABLE_MODE: # Full 2D panning
		if x_ratio < margin_table:
			rotation += Vector3(0, speed_table*delta, 0)
		elif x_ratio > (1.0 - margin_table):
			rotation -= Vector3(0, speed_table*delta, 0)
		if y_ratio < margin_table:
			rotation += Vector3(speed_table*delta, 0, 0)
		elif y_ratio > (1.0 - margin_table):
			rotation -= Vector3(speed_table*delta, 0, 0)
		rotation = rotation.clamp(
			Vector3(deg_to_rad(center_table.x - amplitude_table), deg_to_rad(center_table.y - amplitude_table), 0),
			Vector3(deg_to_rad(center_table.x + amplitude_table), deg_to_rad(center_table.y + amplitude_table), 0)
		)
		if rotation.x < deg_to_rad(center_table.x - amplitude_table + .2):
			switch_mode(ViewMode.HAND_MODE)

var tween: Tween = null
func switch_mode(mode: ViewMode) -> void:
	current_mode = ViewMode.IN_TRANSITION
	if tween:
		tween.stop()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	if mode == ViewMode.TABLE_MODE:
		HandFrontView.disable()
		tween.parallel().tween_property(Rail, "progress_ratio", 0.99, 1)
		tween.parallel().tween_property(self, "rotation", Vector3(deg_to_rad(center_table.x), deg_to_rad(center_table.y), 0), 1)
		tween.tween_callback(func ():
			current_mode = ViewMode.TABLE_MODE
			HandTopView.enable()
		)
	else:
		HandTopView.disable()
		tween.parallel().tween_property(Rail, "progress_ratio", 0.01, 1)
		tween.parallel().tween_property(self, "rotation", Vector3(deg_to_rad(center_hand.x), deg_to_rad(center_hand.y), 0), 1)
		tween.tween_callback(func ():
			current_mode = ViewMode.HAND_MODE
			HandFrontView.enable()
		)

func _exit_tree() -> void:
	if tween:
		tween.stop()
