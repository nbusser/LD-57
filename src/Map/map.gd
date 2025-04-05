extends Node3D

@onready var hand: CharacterBody3D = $Hand/HandBody
@onready var cardScene: PackedScene = preload("res://src/Card.tscn")

const plane_collision_layer = 6

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	var ray_origin = cam.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + cam.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 1 << plane_collision_layer - 1)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result:
		hand.global_position = result.position


func _ready():
	for i in range(5):
		spawn_card()

func spawn_card():
	var card = cardScene.instantiate()
	card.add_to_group("cards")
	add_child(card)
	card.global_position = get_viewport().get_camera_3d().global_position + get_viewport().get_camera_3d().basis.z * -.5
