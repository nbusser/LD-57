extends Node3D

const CARD_LAYER = 7

@onready var camera = $"../../../../CameraRail/FollowRail/Camera"

# TODO @mbty remove; just pay attention to collision_mask
var pointed_location = Vector3()
var pointed_direction = Vector3()
var pointed_card = null

@export var dist_out : float = 10.0

func _ready() -> void:
	pointed_location = Vector3(0.0, dist_out, 0.0)
	pointed_direction = Vector3(1.0, 0.0, 0.0)

func _physics_process(_delta: float) -> void:
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.global_position
	ray_query.to = global_position
	ray_query.collision_mask = 1 << CARD_LAYER - 1
	var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)

	pointed_direction = ray_query.from - ray_query.to
	if results:
		pointed_location = results.position
		if results.collider.is_in_group("grabbable_cards"):
			pointed_card = results.collider
	else:
		pointed_location = ray_query.from + pointed_direction * dist_out

func get_closest_card() -> Card:
	return pointed_card
