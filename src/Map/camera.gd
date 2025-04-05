extends Camera3D

@onready var rail = get_node("..")

@export var margin_hand = .1
@export var speed_hand = 1
@export var amplitude_hand = 10 # degrees
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
		if y_ratio < margin_hand:
			rotation += Vector3(speed_hand*delta, 0, 0)
		elif y_ratio > (1.0 - margin_hand):
			rotation -= Vector3(speed_hand*delta, 0, 0)
		rotation = rotation.clamp(
			Vector3(deg_to_rad(center_hand.x - amplitude_hand), deg_to_rad(center_hand.y - amplitude_hand), 0),
			Vector3(deg_to_rad(center_hand.x + amplitude_hand), deg_to_rad(center_hand.y + amplitude_hand), 0)
		)
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

var tween: Tween = null
func _on_weeeee_toggled(toggled_on: bool) -> void:
	current_mode = ViewMode.IN_TRANSITION
	if tween:
		tween.stop()
	tween = get_tree().create_tween()
	if toggled_on:
		tween.parallel().tween_property(rail, "progress_ratio", 0.99, 1)
		tween.parallel().tween_property(self, "rotation", Vector3(deg_to_rad(center_table.x), deg_to_rad(center_table.y), 0), 1)
		tween.tween_callback(func (): current_mode = ViewMode.TABLE_MODE)
	else:
		tween.parallel().tween_property(rail, "progress_ratio", 0.01, 1)
		tween.parallel().tween_property(self, "rotation", Vector3(deg_to_rad(center_hand.x + amplitude_hand), deg_to_rad(center_hand.y), 0), 1)
		tween.tween_callback(func (): current_mode = ViewMode.HAND_MODE)
