extends Node3D

@onready var hand: CharacterBody3D = $Hand/HandBody
@onready var fixed_arm: Node3D = $FixedArm
@onready var cardScene: PackedScene = preload("res://src/Card.tscn")

@onready var stencil_viewport : SubViewport = $StencilViewport
@onready var stencil_camera : Camera3D = $StencilViewport/Camera3D

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

	var viewport := get_viewport()
	var current_camera := viewport.get_camera_3d()

	if stencil_viewport.size != viewport.size:
		stencil_viewport.size = viewport.size

	if current_camera:
		stencil_camera.fov = current_camera.fov
		stencil_camera.global_transform = current_camera.global_transform


func _ready():
	spawn_cards(5)

const CARD_THICKNESS = 0.0003 # .3mm
const VERTICAL_OFFSET = Vector3.DOWN * 0.06
func spawn_cards(num_cards: int):
	var angle_step = PI/12
	var total_angle = angle_step * num_cards
	var start_angle = -total_angle / 2

	for i in range(num_cards):
		var card: Node3D = cardScene.instantiate()
		card.add_to_group("cards")
		fixed_arm.add_child(card)

		var angle = start_angle + (angle_step * i)
		card.transform = card.transform.rotated_local(Vector3.LEFT, PI / 2)
		card.transform = card.transform.translated(-VERTICAL_OFFSET).rotated(Vector3.FORWARD, angle).translated(VERTICAL_OFFSET).translated(Vector3.BACK * CARD_THICKNESS * i)
