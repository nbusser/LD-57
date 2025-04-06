extends Node2D

const CARD_LAYER = 7

@onready var camera = $"../../../../../CameraRail/FollowRail/Camera"


func get_closest_card() -> Card:
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.project_ray_origin(global_position)
	ray_query.to = ray_query.from + camera.project_ray_normal(global_position) * 100
	ray_query.collision_mask = 1 << CARD_LAYER - 1
	var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)

	if results && results.collider.is_in_group("grabbable_cards"):
		return results.collider
	return null
