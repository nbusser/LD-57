extends Node3D

const PLANE_COLLISION_LAYER = 6

const CARD_THICKNESS = 0.0003  # .3mm
const VERTICAL_OFFSET = Vector3.DOWN * 0.06

var selected = null

@onready var hand: Hand = $Hand
@onready var fixed_arm: Node3D = $FixedArm
@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var finger_tip = $"2DHand/HandBody/Sprite2D/FingerTip"

@onready var stencil_viewport: SubViewport = $StencilViewport
@onready var stencil_camera: Camera3D = $StencilViewport/Camera3D


func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	var ray_origin = cam.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + cam.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		ray_origin, ray_end, 1 << PLANE_COLLISION_LAYER - 1
	)
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

	var card: StaticBody3D = null
	if hand.enabled:
		card = hand.get_closest_card()
	else:  # Use FrontView hand
		card = finger_tip.get_closest_card()

	if card:
		(card.get_node("CardMesh") as MeshInstance3D).set_layer_mask_value(6, true)
		if selected and card != selected:
			(selected.get_node("CardMesh") as MeshInstance3D).set_layer_mask_value(6, false)
		selected = card


func _ready():
	spawn_cards(5)


func spawn_cards(num_cards: int):
	var angle_step = PI / 12
	var total_angle = angle_step * num_cards
	var start_angle = -total_angle / 2

	for i in range(num_cards):
		var card: Node3D = card_scene.instantiate()
		card.init(1)
		card.add_to_group("cards")
		fixed_arm.add_child(card)

		var angle = start_angle + (angle_step * i)
		card.transform = card.transform.rotated_local(Vector3.LEFT, PI / 2)
		card.transform = (
			card
			. transform
			. translated(-VERTICAL_OFFSET)
			. rotated(Vector3.FORWARD, angle)
			. translated(VERTICAL_OFFSET)
			. translated(Vector3.BACK * CARD_THICKNESS * i)
		)
