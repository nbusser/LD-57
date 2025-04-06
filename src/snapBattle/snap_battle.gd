extends Node3D

@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if camera.rail.progress_ratio >= .6:
		$Sprite3D.texture = load("res://assets/sprites/battlefield_glow.png")
	else:
		$Sprite3D.texture = load("res://assets/sprites/battlefield.png")
