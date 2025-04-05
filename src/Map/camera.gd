extends Camera3D

@export var margin_prop = .1
@export var speed = 1
@export var amplitude = 20 # degrees

@onready var rail = get_node("..")

func _physics_process(delta: float) -> void:
	var y_ratio = get_viewport().get_mouse_position().y/get_viewport().get_size().y
	if y_ratio < margin_prop:
		rotation += Vector3(speed*delta, 0, 0)
	elif y_ratio > (1.0 - margin_prop):
		rotation -= Vector3(speed*delta, 0, 0)
	rotation = rotation.clamp(
		Vector3(deg_to_rad(-20 - amplitude), deg_to_rad(-amplitude), 0),
		Vector3(deg_to_rad(-20 + amplitude), deg_to_rad(amplitude), 0)
	)

func _on_weeeee_toggled(toggled_on: bool) -> void:
	var tween = get_tree().create_tween()
	if toggled_on:
		tween.tween_property(rail, "progress_ratio", 0.99, 1)
	else:
		tween.tween_property(rail, "progress_ratio", 0.01, 1)
