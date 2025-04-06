extends CharacterBody3D

@onready var camera = get_node("../../CameraRail/FollowRail/Camera")

var coords_2D = Vector2()

func _ready() -> void:
	coords_2D = camera.unproject_position(global_position)

func _process(delta: float) -> void:
	# Retroprojection
	coords_2D = camera.unproject_position(global_position)
